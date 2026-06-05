import { useEffect, useState } from 'react'
import { useNavigate, useParams } from 'react-router-dom'
import { Button, Avatar, LabelMono, Divider, Pill, Card } from '../components/UI'
import { getBooking, patchBooking, deleteBooking } from '../data/bookingsApi'
import { useT, useSettings } from '../i18n/SettingsContext'
import { useConfirm } from '../components/Confirm'
import { useToast } from '../components/Toast'
import { Skeleton, useDelayedFlag } from '../components/Skeleton'
import EmptyState from '../components/EmptyState'
import { downloadIcs } from '../utils/ics'
import type { Booking, Lang } from '../types'

function formatDate(iso: string | undefined, lang: Lang): string {
  if (!iso) return ''
  const [y, m, d] = iso.split('-').map(Number)
  const date = new Date(y, m - 1, d)
  return date.toLocaleDateString(lang === 'ru' ? 'ru-RU' : 'en-US', {
    weekday: 'short', month: 'long', day: 'numeric', year: 'numeric',
  })
}

export default function BookingDetail() {
  const t = useT()
  const { lang } = useSettings()
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
      .then((data) => { if (mounted) { setBooking(data); setError(null) } })
      .catch(() => { if (mounted) setError(t('bookings.detail.notFound')) })
      .finally(() => { if (mounted) setLoading(false) })
    return () => { mounted = false }
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
  if (loading) {
    if (!showSkeleton) return null
    return (
      <div style={{ maxWidth: 720 }}>
        <Skeleton width={80} height={14} style={{ marginBottom: 16 }} />
        <Skeleton width="50%" height={32} style={{ marginBottom: 8 }} />
        <Skeleton width={120} height={14} style={{ marginBottom: 32 }} />
        <Skeleton width="100%" height={120} radius={14} style={{ marginBottom: 24 }} />
        <Skeleton width="100%" height={80} radius={14} style={{ marginBottom: 24 }} />
        <Skeleton width="100%" height={80} radius={14} />
      </div>
    )
  }

  if (error || !booking) {
    return (
      <>
        <button onClick={goBack} className="btn-text" style={{ fontSize: 13, cursor: 'pointer' }}>
          {t('bookings.detail.backToList')}
        </button>
        <EmptyState
          illustration="calendar"
          title={error || t('bookings.detail.notFound')}
        />
      </>
    )
  }

  const ref = `SLT-${String(booking.id).padStart(4, '0')}`
  const timePretty = booking.endTime ? `${booking.time} – ${booking.endTime}` : booking.time
  const isCancelled = booking.status === 'cancelled'

  return (
    <div style={{ maxWidth: 720 }}>
      <button onClick={goBack} className="btn-text" style={{ fontSize: 13, cursor: 'pointer' }}>
        {t('bookings.detail.backToList')}
      </button>

      <div className="flex-between mt-4 mb-2" style={{ alignItems: 'flex-start' }}>
        <h1>{booking.service}</h1>
        <Pill tone={isCancelled ? 'danger' : booking.status === 'confirmed' ? 'success' : 'accent'}>
          {t(`status.${booking.status}`)}
        </Pill>
      </div>
      <p className="subtitle mb-8 mono">#{ref}</p>

      <Card className="mb-6">
        <div className="grid grid-2">
          <div>
            <LabelMono>{t('conf.field.date')}</LabelMono>
            <div style={{ fontWeight: 600, marginTop: 8 }}>{formatDate(booking.dateISO, lang)}</div>
          </div>
          <div>
            <LabelMono>{t('conf.field.time')}</LabelMono>
            <div className="mono" style={{ marginTop: 8 }}>
              {timePretty} ({booking.durationMin || 60} {t('services.minutes')})
            </div>
          </div>
          <div>
            <LabelMono>{t('conf.field.location')}</LabelMono>
            <div style={{ marginTop: 8 }}>{t('conf.location')}</div>
          </div>
          <div>
            <LabelMono>{t('conf.field.total')}</LabelMono>
            <div className="text-accent mono" style={{ marginTop: 8, fontWeight: 600, fontSize: 16 }}>
              ${Number(booking.total || 0).toFixed(2)}
            </div>
          </div>
        </div>
      </Card>

      <Card className="mb-6">
        <LabelMono>{t('bookings.detail.section.customer')}</LabelMono>
        <div className="flex flex-gap-3 mt-4" style={{ alignItems: 'center' }}>
          <Avatar initials={booking.initials || '?'} size={40} />
          <div>
            <div style={{ fontWeight: 600 }}>{booking.withName || '—'}</div>
            <div className="text-muted" style={{ fontSize: 13 }}>{booking.customerEmail}</div>
            {booking.customerPhone && (
              <div className="text-muted mono" style={{ fontSize: 13 }}>{booking.customerPhone}</div>
            )}
          </div>
        </div>
      </Card>

      <Card className="mb-6">
        <LabelMono>{t('bookings.detail.section.notes')}</LabelMono>
        <div
          className={booking.notes ? '' : 'text-subtle'}
          style={{ marginTop: 8, whiteSpace: 'pre-wrap', fontSize: 14 }}
        >
          {booking.notes || t('bookings.detail.noNotes')}
        </div>
      </Card>

      <Divider />

      <div className="flex flex-gap-3 mt-4">
        <Button onClick={() => downloadIcs(booking, `slottr-${ref}.ics`)} disabled={busy}>
          {t('conf.btn.addToCal')}
        </Button>
        {!isCancelled && (
          <Button variant="ghost" onClick={onCancel} disabled={busy} style={{ color: 'var(--warning)' }}>
            {busy ? t('bookings.cancelling') : t('bookings.action.cancel')}
          </Button>
        )}
        <Button variant="ghost" onClick={onDelete} disabled={busy} style={{ color: 'var(--danger)' }}>
          {busy ? t('bookings.deleting') : t('bookings.action.delete')}
        </Button>
      </div>
    </div>
  )
}
