import { Card, LabelMono } from '../../components/UI'
import { useT, useSettings } from '../../i18n/SettingsContext'
import type { Booking } from '../../types'
import { formatBookingDate, getBookingTimeRange } from './bookingDetailUtils'

export default function BookingSummaryCard({ booking }: { booking: Booking }) {
  const t = useT()
  const { lang } = useSettings()

  return (
    <Card className="mb-6">
      <div className="grid grid-2">
        <div>
          <LabelMono>{t('conf.field.date')}</LabelMono>
          <div style={{ fontWeight: 600, marginTop: 8 }}>
            {formatBookingDate(booking.dateISO, lang)}
          </div>
        </div>
        <div>
          <LabelMono>{t('conf.field.time')}</LabelMono>
          <div className="mono" style={{ marginTop: 8 }}>
            {getBookingTimeRange(booking)} ({booking.durationMin || 60} {t('services.minutes')})
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
  )
}
