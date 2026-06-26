import { useEffect, useState } from 'react'
import { useNavigate, useParams } from 'react-router-dom'
import { getBooking, patchBooking, deleteBooking } from '../data/bookingsApi'
import { useT } from '../i18n/SettingsContext'
import { useConfirm } from '../components/Confirm'
import { useToast } from '../components/Toast'
import { useDelayedFlag } from '../components/Skeleton'
import type { Booking } from '../types'
import BookingDetailActions from './booking-detail/BookingDetailActions'
import BookingCustomerCard from './booking-detail/BookingCustomerCard'
import BookingDetailHeader from './booking-detail/BookingDetailHeader'
import { BookingDetailNotFound, BookingDetailSkeleton } from './booking-detail/BookingDetailState'
import BookingNotesCard from './booking-detail/BookingNotesCard'
import BookingSummaryCard from './booking-detail/BookingSummaryCard'

export default function BookingDetail() {
  const t = useT()
  const confirm = useConfirm()
  const toast = useToast()
  const { id } = useParams<{ id: string }>()
  const navigate = useNavigate()

  const [booking, setBooking] = useState<Booking | null>(null)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)
  const [busy, setBusy] = useState(false)

  // Back to wherever the user came from; fallback to /bookings if no history.
  const goBack = () => {
    if (window.history.length > 1) navigate(-1)
    else navigate('/bookings')
  }

  useEffect(() => {
    if (!id) return
    let mounted = true
    setLoading(true)
    getBooking(id)
      .then((data) => {
        if (mounted) {
          setBooking(data)
          setError(null)
        }
      })
      .catch(() => {
        if (mounted) setError(t('bookings.detail.notFound'))
      })
      .finally(() => {
        if (mounted) setLoading(false)
      })
    return () => {
      mounted = false
    }
  }, [id, t])

  const onCancel = async () => {
    if (!booking) return
    const ok = await confirm({
      title: t('bookings.action.cancel'),
      message: t('bookings.cancelConfirm', {
        service: booking.service,
        date: booking.dateISO,
        time: booking.time,
      }),
      confirmText: t('bookings.action.cancel'),
      danger: true,
    })
    if (!ok) return

    try {
      setBusy(true)
      await patchBooking(booking.id, { status: 'cancelled' })
      setBooking({ ...booking, status: 'cancelled' })
      toast.success(t('bookings.action.cancel'))
    } catch (e) {
      toast.error(e instanceof Error ? e.message : 'Failed to cancel')
    } finally {
      setBusy(false)
    }
  }

  const onDelete = async () => {
    if (!booking) return
    const ok = await confirm({
      title: t('bookings.action.delete'),
      message: t('bookings.deleteConfirm', {
        service: booking.service,
        date: booking.dateISO,
        time: booking.time,
      }),
      confirmText: t('bookings.action.delete'),
      danger: true,
    })
    if (!ok) return

    try {
      setBusy(true)
      await deleteBooking(booking.id)
      toast.success(t('bookings.action.delete'))
      navigate('/bookings')
    } catch (e) {
      toast.error(e instanceof Error ? e.message : 'Failed to delete')
      setBusy(false)
    }
  }

  const showSkeleton = useDelayedFlag(loading)
  if (loading) return showSkeleton ? <BookingDetailSkeleton /> : null

  if (error || !booking) {
    return <BookingDetailNotFound title={error || t('bookings.detail.notFound')} onBack={goBack} />
  }

  return (
    <div style={{ maxWidth: 720 }}>
      <BookingDetailHeader booking={booking} onBack={goBack} />
      <BookingSummaryCard booking={booking} />
      <BookingCustomerCard booking={booking} />
      <BookingNotesCard booking={booking} />
      <BookingDetailActions booking={booking} busy={busy} onCancel={onCancel} onDelete={onDelete} />
    </div>
  )
}
