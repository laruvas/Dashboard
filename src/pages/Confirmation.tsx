import { Link } from 'react-router-dom'
import { Button, Avatar, LabelMono, Divider } from '../components/UI'
import { IconCheck } from '../components/Icons'
import { useT, useSettings } from '../i18n/SettingsContext'
import { downloadIcs } from '../utils/ics'
import type { Booking, Lang } from '../types'

function safeParse(str: string | null): Booking | null {
  if (!str) return null
  try {
    return JSON.parse(str) as Booking
  } catch {
    return null
  }
}

function formatDate(iso: string | undefined, lang: Lang): string {
  if (!iso) return ''
  const [y, m, d] = iso.split('-').map(Number)
  const date = new Date(y, m - 1, d)
  return date.toLocaleDateString(lang === 'ru' ? 'ru-RU' : 'en-US', {
    weekday: 'short',
    month: 'long',
    day: 'numeric',
    year: 'numeric',
  })
}

export default function Confirmation() {
  const t = useT()
  const { lang } = useSettings()

  const booking =
    typeof window !== 'undefined' ? safeParse(sessionStorage.getItem('lastBooking')) : null

  if (!booking) {
    return (
      <div className="card" style={{ maxWidth: 560, marginTop: 80 }}>
        <h1 className="mb-2">{t('conf.noBooking')}</h1>
        <p className="subtitle mb-8">{t('conf.noBookingSub')}</p>

        <div className="flex flex-gap-3">
          <Button as="link" to="/booking">
            {t('conf.createBooking')}
          </Button>
          <Button as="link" to="/bookings" variant="ghost">
            {t('conf.viewBookings')}
          </Button>
          <Link
            to="/dashboard"
            className="btn-text"
            style={{ marginLeft: 'auto', alignSelf: 'center' }}
          >
            {t('conf.backToDashboard')}
          </Link>
        </div>
      </div>
    )
  }

  const ref = `SLT-${String(booking.id).padStart(4, '0')}`
  const timePretty = booking.endTime ? `${booking.time} – ${booking.endTime}` : booking.time

  return (
    <div style={{ maxWidth: 560, marginTop: 80 }}>
      <div
        style={{
          width: 48,
          height: 48,
          borderRadius: 12,
          background: 'var(--accent-soft)',
          display: 'grid',
          placeItems: 'center',
          marginBottom: 24,
        }}
      >
        <IconCheck width={24} height={24} stroke="var(--accent)" strokeWidth={2.2} />
      </div>

      <h1 className="mb-2">{t('conf.youreBooked')}</h1>

      <p className="subtitle mb-8">
        {t('conf.confirmationSentTo')}{' '}
        <span style={{ color: 'var(--text)' }}>{booking.customerEmail}</span>.{' '}
        {t('conf.addToCalendar')}
      </p>

      <div className="card mb-6">
        <div className="grid grid-2">
          <div>
            <LabelMono>{t('conf.field.service')}</LabelMono>
            <div style={{ fontWeight: 600, marginTop: 8 }}>{booking.service}</div>
          </div>
          <div>
            <LabelMono>{t('conf.field.reference')}</LabelMono>
            <div className="mono" style={{ marginTop: 8 }}>
              #{ref}
            </div>
          </div>
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
            <LabelMono>{t('conf.field.with')}</LabelMono>
            <div className="flex flex-gap-2" style={{ alignItems: 'center', marginTop: 8 }}>
              <Avatar initials={booking.initials || 'EM'} size={24} />
              <span style={{ fontWeight: 600 }}>{booking.withName || 'Emily Martinez'}</span>
            </div>
          </div>
          <div>
            <LabelMono>{t('conf.field.location')}</LabelMono>
            <div style={{ marginTop: 8 }}>{t('conf.location')}</div>
          </div>
        </div>

        {booking.notes && (
          <>
            <Divider />
            <LabelMono>{t('conf.field.notes')}</LabelMono>
            <div style={{ marginTop: 8, whiteSpace: 'pre-wrap', fontSize: 14 }}>
              {booking.notes}
            </div>
          </>
        )}

        <Divider />

        <div className="flex-between">
          <span className="text-muted">{t('conf.field.total')}</span>
          <span className="text-accent mono" style={{ fontSize: 18, fontWeight: 600 }}>
            ${Number(booking.total || 0).toFixed(2)}
          </span>
        </div>
      </div>

      <div className="flex flex-gap-3">
        <Button onClick={() => downloadIcs(booking, `slottr-${ref}.ics`)}>
          {t('conf.btn.addToCal')}
        </Button>
        <Button as="link" to={`/bookings/${booking.id}`} variant="ghost">
          {t('conf.btn.manage')}
        </Button>
        <Link
          to="/dashboard"
          className="btn-text"
          style={{ marginLeft: 'auto', alignSelf: 'center' }}
        >
          {t('common.done')}
        </Link>
      </div>
    </div>
  )
}
