import { Card, LabelMono } from '../../components/UI'
import { useT } from '../../i18n/SettingsContext'
import type { Booking } from '../../types'

export default function BookingNotesCard({ booking }: { booking: Booking }) {
  const t = useT()

  return (
    <Card className="mb-6">
      <LabelMono>{t('bookings.detail.section.notes')}</LabelMono>
      <div
        className={booking.notes ? '' : 'text-subtle'}
        style={{ marginTop: 8, whiteSpace: 'pre-wrap', fontSize: 14 }}
      >
        {booking.notes || t('bookings.detail.noNotes')}
      </div>
    </Card>
  )
}
