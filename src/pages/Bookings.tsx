import { useCallback, useEffect, useMemo, useState } from 'react'
import RescheduleModal from '../components/RescheduleModal'
import { listBookings, deleteBooking, patchBooking } from '../data/bookingsApi'
import { useT, useSettings } from '../i18n/SettingsContext'
import { useConfirm } from '../components/Confirm'
import { useToast } from '../components/Toast'
import { useDelayedFlag } from '../components/Skeleton'
import type { Booking } from '../types'
import type { TabItem } from '../components/UI'
import BookingsHeader from './bookings/BookingsHeader'
import BookingsFilters from './bookings/BookingsFilters'
import BookingsTable from './bookings/BookingsTable'
import {
  BookingsError,
  BookingsSkeleton,
  EmptyBookingsState,
  FirstRunEmptyState,
} from './bookings/BookingsState'
import type { StatusTab } from './bookings/bookingsTypes'
import {
  addMinutesHHMM,
  annotateBookings,
  filterBookings,
  formatDateShort,
  groupBookingsByStatus,
  sortBookings,
} from './bookings/bookingsUtils'

export default function Bookings() {
  const t = useT()
  const { lang } = useSettings()
  const confirm = useConfirm()
  const toast = useToast()

  const [status, setStatus] = useState<StatusTab>('upcoming')
  const [query, setQuery] = useState('')
  const [editing, setEditing] = useState<Booking | null>(null)
  const [bookings, setBookings] = useState<Booking[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)
  const [busyId, setBusyId] = useState<string | null>(null)

  const load = useCallback(() => {
    setLoading(true)
    listBookings()
      .then((data) => {
        setBookings(sortBookings(data))
        setError(null)
      })
      .catch(() => setError(t('bookings.errorServer')))
      .finally(() => setLoading(false))
  }, [t])

  useEffect(() => {
    load()
  }, [load])

  // Wrap into uniform shape so downstream code (which used to read `.b`/`.role`)
  // still works after the role-split was removed in the single-tenant refactor.
  const annotated = useMemo(() => annotateBookings(bookings), [bookings])
  const groups = useMemo(() => groupBookingsByStatus(annotated), [annotated])
  const visible = useMemo(() => filterBookings(groups, status, query), [groups, status, query])

  const handleReschedule = async (dateISO: string, time: string) => {
    if (!editing) return
    const endTime = addMinutesHHMM(time, editing.durationMin || 60)
    const updated = await patchBooking(editing.id, { dateISO, time, endTime })
    setBookings((prev) => prev.map((x) => (x.id === editing.id ? { ...x, ...updated } : x)))
    toast.success(t('common.save'))
  }

  const handleCancel = async (b: Booking) => {
    const ok = await confirm({
      title: t('bookings.action.cancel'),
      message: t('bookings.cancelConfirm', {
        service: b.service,
        date: formatDateShort(b.dateISO, lang),
        time: b.time,
      }),
      confirmText: t('bookings.action.cancel'),
      danger: true,
    })
    if (!ok) return

    try {
      setBusyId(b.id)
      await patchBooking(b.id, { status: 'cancelled' })
      setBookings((prev) => prev.map((x) => (x.id === b.id ? { ...x, status: 'cancelled' } : x)))
      toast.success(t('bookings.action.cancel'))
    } catch (e) {
      toast.error(e instanceof Error ? e.message : 'Failed to cancel booking')
    } finally {
      setBusyId(null)
    }
  }

  const handleDelete = async (b: Booking) => {
    const ok = await confirm({
      title: t('bookings.action.delete'),
      message: t('bookings.deleteConfirm', {
        service: b.service,
        date: formatDateShort(b.dateISO, lang),
        time: b.time,
      }),
      confirmText: t('bookings.action.delete'),
      danger: true,
    })
    if (!ok) return

    try {
      setBusyId(b.id)
      await deleteBooking(b.id)
      setBookings((prev) => prev.filter((x) => x.id !== b.id))
      toast.success(t('bookings.action.delete'))
    } catch (e) {
      toast.error(e instanceof Error ? e.message : 'Failed to delete booking')
    } finally {
      setBusyId(null)
    }
  }

  // Hide tab counts while loading — they'd flicker from 0 → N once data arrives.
  const count = (n: number) => (loading ? undefined : n)
  const tabs: TabItem<StatusTab>[] = [
    { value: 'upcoming', label: t('bookings.tab.upcoming'), count: count(groups.upcoming.length) },
    { value: 'past', label: t('bookings.tab.past'), count: count(groups.past.length) },
    {
      value: 'cancelled',
      label: t('bookings.tab.cancelled'),
      count: count(groups.cancelled.length),
    },
  ]

  const showSkeleton = useDelayedFlag(loading)
  const isFirstRun = !loading && !error && annotated.length === 0

  return (
    <>
      <BookingsHeader loading={loading} onRefresh={load} />

      {!isFirstRun && (
        <BookingsFilters
          tabs={tabs}
          status={status}
          query={query}
          onStatusChange={setStatus}
          onQueryChange={setQuery}
        />
      )}

      {error && <BookingsError error={error} />}
      {!error && loading && showSkeleton && <BookingsSkeleton />}
      {isFirstRun && <FirstRunEmptyState />}
      {!error && !loading && !isFirstRun && visible.length === 0 && (
        <EmptyBookingsState status={status} query={query} />
      )}
      {visible.length > 0 && (
        <BookingsTable
          items={visible}
          status={status}
          busyId={busyId}
          onEdit={setEditing}
          onCancel={handleCancel}
          onDelete={handleDelete}
        />
      )}

      <RescheduleModal
        booking={editing}
        onClose={() => setEditing(null)}
        onSubmit={handleReschedule}
      />
    </>
  )
}
