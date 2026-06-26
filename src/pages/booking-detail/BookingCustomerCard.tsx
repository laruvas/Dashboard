import { Avatar, Card, LabelMono } from '../../components/UI'
import { useT } from '../../i18n/SettingsContext'
import type { Booking } from '../../types'

export default function BookingCustomerCard({ booking }: { booking: Booking }) {
  const t = useT()

  return (
    <Card className="mb-6">
      <LabelMono>{t('bookings.detail.section.customer')}</LabelMono>
      <div className="flex flex-gap-3 mt-4" style={{ alignItems: 'center' }}>
        <Avatar initials={booking.initials || '?'} size={40} />
        <div>
          <div style={{ fontWeight: 600 }}>{booking.withName || '—'}</div>
          <div className="text-muted" style={{ fontSize: 13 }}>
            {booking.customerEmail}
          </div>
          {booking.customerPhone && (
            <div className="text-muted mono" style={{ fontSize: 13 }}>
              {booking.customerPhone}
            </div>
          )}
        </div>
      </div>
    </Card>
  )
}
