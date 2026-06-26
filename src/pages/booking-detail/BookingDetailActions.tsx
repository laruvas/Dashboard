import { Button, Divider } from '../../components/UI'
import { useT } from '../../i18n/SettingsContext'
import { downloadIcs } from '../../utils/ics'
import type { Booking } from '../../types'
import { getBookingRef } from './bookingDetailUtils'

interface BookingDetailActionsProps {
  booking: Booking
  busy: boolean
  onCancel: () => void
  onDelete: () => void
}

export default function BookingDetailActions({
  booking,
  busy,
  onCancel,
  onDelete,
}: BookingDetailActionsProps) {
  const t = useT()
  const isCancelled = booking.status === 'cancelled'
  const ref = getBookingRef(booking.id)

  return (
    <>
      <Divider />

      <div className="flex flex-gap-3 mt-4">
        <Button onClick={() => downloadIcs(booking, `slottr-${ref}.ics`)} disabled={busy}>
          {t('conf.btn.addToCal')}
        </Button>
        {!isCancelled && (
          <Button
            variant="ghost"
            onClick={onCancel}
            disabled={busy}
            style={{ color: 'var(--warning)' }}
          >
            {busy ? t('bookings.cancelling') : t('bookings.action.cancel')}
          </Button>
        )}
        <Button
          variant="ghost"
          onClick={onDelete}
          disabled={busy}
          style={{ color: 'var(--danger)' }}
        >
          {busy ? t('bookings.deleting') : t('bookings.action.delete')}
        </Button>
      </div>
    </>
  )
}
