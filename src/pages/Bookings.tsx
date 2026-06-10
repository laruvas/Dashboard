import { useEffect, useMemo, useState, type ReactNode } from 'react'
import { Link } from 'react-router-dom'
import { Button, Pill, Avatar, Tabs, type TabItem } from '../components/UI'
import { IconSearch } from '../components/Icons'
import RescheduleModal from '../components/RescheduleModal'
import { listBookings, deleteBooking, patchBooking } from '../data/bookingsApi'
import { useT, useSettings } from '../i18n/SettingsContext'
import { useConfirm } from '../components/Confirm'
import { useToast } from '../components/Toast'
import EmptyState from '../components/EmptyState'
import { SkeletonTableRow, useDelayedFlag } from '../components/Skeleton'
import type { Booking, Lang } from '../types'

type StatusTab = 'upcoming' | 'past' | 'cancelled'
function formatDateShort(iso: string | undefined, lang: Lang): string {
  if (!iso) return '—'
  const [y, m, d] = iso.split('-').map(Number)
  const date = new Date(y, m - 1, d)
  return date.toLocaleDateString(lang === 'ru' ? 'ru-RU' : 'en-US', { month: 'short', day: 'numeric' })
}

function toISODate(d: Date): string {
  const yyyy = d.getFullYear()
  const mm = String(d.getMonth() + 1).padStart(2, '0')
  const dd = String(d.getDate()).padStart(2, '0')
  return `${yyyy}-${mm}-${dd}`
}

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

  const load = () => {
    setLoading(true)
    listBookings()
      .then((data) => {
        const sorted = [...data].sort((a, b) => {
          const byDate = (a.dateISO || '').localeCompare(b.dateISO || '')
          if (byDate !== 0) return byDate
          return (a.time || '').localeCompare(b.time || '')
        })
        setBookings(sorted)
        setError(null)
      })
      .catch(() => setError(t('bookings.errorServer')))
      .finally(() => setLoading(false))
  }
  useEffect(() => { load() }, [])  // eslint-disable-line react-hooks/exhaustive-deps

  // Wrap into uniform shape so downstream code (which used to read `.b`/`.role`)
  // still works after the role-split was removed in the single-tenant refactor.
  const annotated = useMemo(() => bookings.map(b => ({ b })), [bookings])

  // Split into status groups: upcoming / past / cancelled.
  const groups = useMemo(() => {
    const todayISO = toISODate(new Date())
    const upcoming: typeof annotated = []
    const past: typeof annotated = []
    const cancelled: typeof annotated = []
    for (const x of annotated) {
      if (x.b.status === 'cancelled') cancelled.push(x)
      else if ((x.b.dateISO || '') >= todayISO) upcoming.push(x)
      else past.push(x)
    }
    return { upcoming, past, cancelled }
  }, [annotated])

  const visible = useMemo(() => {
    const list = groups[status] || []
    const q = query.trim().toLowerCase()
    if (!q) return list
    return list.filter(({ b }) =>
      (b.withName || '').toLowerCase().includes(q) ||
      (b.service  || '').toLowerCase().includes(q) ||
      (b.customerEmail || '').toLowerCase().includes(q) ||
      (b.dateISO  || '').includes(q),
    )
  }, [groups, status, query])

  const handleReschedule = async (dateISO: string, time: string) => {
    if (!editing) return
    const endTime = (() => {
      const [hStr, mStr] = time.split(':')
      const total = Number(hStr) * 60 + Number(mStr) + (editing.durationMin || 60)
      return `${String(Math.floor(total / 60) % 24).padStart(2, '0')}:${String(total % 60).padStart(2, '0')}`
    })()
    const updated = await patchBooking(editing.id, { dateISO, time, endTime })
    setBookings(prev => prev.map(x => x.id === editing.id ? { ...x, ...updated } : x))
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
      setBookings(prev => prev.map(x => x.id === b.id ? { ...x, status: 'cancelled' } : x))
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
      setBookings(prev => prev.filter(x => x.id !== b.id))
      toast.success(t('bookings.action.delete'))
    } catch (e) {
      toast.error(e instanceof Error ? e.message : 'Failed to delete booking')
    } finally {
      setBusyId(null)
    }
  }

  // Hide tab counts while loading — they'd flicker from 0 → N once data arrives.
  const c = (n: number) => loading ? undefined : n
  const STATUS_TABS: TabItem<StatusTab>[] = [
    { value: 'upcoming',  label: t('bookings.tab.upcoming'),  count: c(groups.upcoming.length) },
    { value: 'past',      label: t('bookings.tab.past'),      count: c(groups.past.length) },
    { value: 'cancelled', label: t('bookings.tab.cancelled'), count: c(groups.cancelled.length) },
  ]

  const showSkeleton = useDelayedFlag(loading)

  // First-run case: no bookings at all (any scope, any status). Show a friendly
  // onboarding empty regardless of which tab the user happens to be on.
  const isFirstRun = !loading && !error && annotated.length === 0

  // Empty-state copy per status tab. Upcoming empty offers the "new booking" CTA;
  // past/cancelled just describe themselves.
  const titleMap: Record<StatusTab, string> = {
    upcoming:  t('bookings.empty.upcoming'),
    past:      t('bookings.empty.past'),
    cancelled: t('bookings.empty.cancelled'),
  }
  const descMap: Record<StatusTab, string> = {
    upcoming:  t('bookings.empty.upcoming.desc'),
    past:      t('bookings.empty.past.desc'),
    cancelled: t('bookings.empty.cancelled.desc'),
  }
  const empty: { title: string; description: string; action?: ReactNode } = {
    title: titleMap[status],
    description: descMap[status],
    action: status === 'upcoming'
      ? <Button as="link" to="/booking">+ {t('nav.newBooking')}</Button>
      : undefined,
  }

  return (
    <>
      <div className="flex-between mb-6">
        <div>
          <h1>{t('bookings.title')}</h1>
          <p className="subtitle mt-2">{t('bookings.subtitle')}</p>
        </div>
        <div className="flex flex-gap-2">
          <Button variant="ghost" size="sm" onClick={load} disabled={loading}>
            {loading ? t('common.loading') : t('common.refresh')}
          </Button>
          <Button as="link" to="/booking" size="sm">+ {t('nav.newBooking')}</Button>
        </div>
      </div>

      {!isFirstRun && (
        <>
          <Tabs items={STATUS_TABS} value={status} onChange={setStatus} />
          <div
            className="mb-4"
            style={{
              background: 'var(--bg-elev-1)',
              border: '1px solid var(--border)',
              borderRadius: 'var(--r-md)',
              padding: 'var(--s-2) var(--s-3)',
              display: 'flex', alignItems: 'center', gap: 'var(--s-2)',
              maxWidth: 420,
            }}
          >
            <IconSearch style={{ color: 'var(--text-muted)' }} />
            <input
              type="search"
              value={query}
              onChange={(e) => setQuery(e.target.value)}
              placeholder={t('bookings.search.placeholder')}
              style={{
                flex: 1, border: 'none', outline: 'none', background: 'none',
                color: 'var(--text)', fontSize: 13,
              }}
            />
          </div>
        </>
      )}

      {error && (
        <div className="mb-4" style={{
          padding: '12px 16px', border: '1px solid rgba(248,113,113,0.32)',
          background: 'rgba(248,113,113,0.12)', color: 'var(--danger)',
          borderRadius: 'var(--r-md)', fontSize: 13,
        }}>{error}</div>
      )}

      {!error && loading && showSkeleton && (
        <table className="table">
          <thead>
            <tr>
              <th>{t('table.date')}</th><th>{t('table.time')}</th>
              <th>{t('table.service')}</th><th>{t('table.with')}</th>
              <th>{t('table.status')}</th><th>{t('table.total')}</th>
              <th />
            </tr>
          </thead>
          <tbody>
            {Array.from({ length: 5 }, (_, i) => <SkeletonTableRow key={i} cols={7} />)}
          </tbody>
        </table>
      )}

      {isFirstRun && (
        <EmptyState
          illustration="calendar"
          title={t('bookings.empty.first')}
          description={t('bookings.empty.first.desc')}
          action={
            <div className="flex flex-gap-2">
              <Button as="link" to="/booking">+ {t('nav.newBooking')}</Button>
              <Button as="link" to="/services" variant="ghost">{t('services.add')}</Button>
            </div>
          }
        />
      )}

      {!error && !loading && !isFirstRun && visible.length === 0 && (
        query.trim()
          ? <EmptyState illustration="search" title={t('bookings.search.empty')} />
          : <EmptyState
              illustration="calendar"
              title={empty.title}
              description={empty.description}
              action={empty.action}
            />
      )}

      {visible.length > 0 && (
        <table className="table">
          <thead>
            <tr>
              <th>{t('table.date')}</th><th>{t('table.time')}</th>
              <th>{t('table.service')}</th><th>{t('table.with')}</th>
              <th>{t('table.status')}</th><th>{t('table.total')}</th>
              <th style={{ textAlign: 'right' }}>{t('table.actions')}</th>
            </tr>
          </thead>
          <tbody>
            {visible.map(({ b }) => {
              const isBusy = busyId === b.id
              const showCancel = status === 'upcoming'

              return (
                <tr key={b.id}>
                  <td className="mono">{formatDateShort(b.dateISO, lang)}</td>
                  <td className="mono">{b.time}</td>
                  <td>{b.service}</td>
                  <td>
                    <div className="flex flex-gap-2" style={{ alignItems: 'center' }}>
                      <Avatar initials={b.initials || '?'} size={24} />
                      {b.withName || '—'}
                    </div>
                  </td>
                  <td>
                    <Pill tone={
                      b.status === 'confirmed' ? 'success' :
                      b.status === 'cancelled' ? 'danger'  : 'accent'
                    }>
                      {t(`status.${b.status}`)}
                    </Pill>
                  </td>
                  <td className="mono">${b.total}</td>
                  <td style={{ textAlign: 'right' }}>
                    <div className="flex flex-gap-2" style={{ justifyContent: 'flex-end' }}>
                      <Link to={`/bookings/${b.id}`} className="btn-text">{t('action.view')}</Link>
                      {showCancel && (
                        <>
                          <button
                            onClick={() => setEditing(b)}
                            disabled={isBusy}
                            className="btn-text"
                            style={{ cursor: 'pointer' }}
                          >
                            {t('bookings.action.edit')}
                          </button>
                          <button
                            onClick={() => handleCancel(b)}
                            disabled={isBusy}
                            className="btn-text"
                            style={{ color: 'var(--warning)', cursor: 'pointer' }}
                          >
                            {isBusy ? t('bookings.cancelling') : t('bookings.action.cancel')}
                          </button>
                        </>
                      )}
                      <button
                        onClick={() => handleDelete(b)}
                        disabled={isBusy}
                        className="btn-text"
                        style={{ color: 'var(--danger)', cursor: 'pointer' }}
                      >
                        {isBusy ? t('bookings.deleting') : t('bookings.action.delete')}
                      </button>
                    </div>
                  </td>
                </tr>
              )
            })}
          </tbody>
        </table>
      )}

      <RescheduleModal
        booking={editing}
        onClose={() => setEditing(null)}
        onSubmit={handleReschedule}
      />
    </>
  )
}
