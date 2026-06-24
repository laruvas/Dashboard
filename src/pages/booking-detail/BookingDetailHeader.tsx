import { Pill } from '../../components/UI'
import { useT } from '../../i18n/SettingsContext'
import type { Booking } from '../../types'
import { getBookingRef, getStatusTone } from './bookingDetailUtils'

interface BookingDetailHeaderProps {
  booking: Booking
  onBack: () => void
}

export default function BookingDetailHeader({ booking, onBack }: BookingDetailHeaderProps) {
  const t = useT()

  return (
    <>
      <button onClick={onBack} className="btn-text" style={{ fontSize: 13, cursor: 'pointer' }}>
        {t('bookings.detail.backToList')}
      </button>

      <div className="flex-between mt-4 mb-2" style={{ alignItems: 'flex-start' }}>
        <h1>{booking.service}</h1>
        <Pill tone={getStatusTone(booking.status)}>{t(`status.${booking.status}`)}</Pill>
      </div>
      <p className="subtitle mb-8 mono">#{getBookingRef(booking.id)}</p>
    </>
  )
}
