import { Link } from 'react-router-dom'
import { Avatar, Pill } from '../../components/UI'
import { useT, useSettings } from '../../i18n/SettingsContext'
import type { Booking } from '../../types'
import type { AnnotatedBooking, StatusTab } from './bookingsTypes'
import { formatDateShort } from './bookingsUtils'

interface BookingsTableProps {
  items: AnnotatedBooking[]
  status: StatusTab
  busyId: string | null
  onEdit: (booking: Booking) => void
  onCancel: (booking: Booking) => void
  onDelete: (booking: Booking) => void
}

export default function BookingsTable({
  items,
  status,
  busyId,
  onEdit,
  onCancel,
  onDelete,
}: BookingsTableProps) {
  const t = useT()
  const { lang } = useSettings()

  return (
    <table className="table">
      <BookingsTableHead actions />
      <tbody>
        {items.map(({ b }) => {
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
                  b.status === 'cancelled' ? 'danger' : 'accent'
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
                        onClick={() => onEdit(b)}
                        disabled={isBusy}
                        className="btn-text"
                        style={{ cursor: 'pointer' }}
                      >
                        {t('bookings.action.edit')}
                      </button>
                      <button
                        onClick={() => onCancel(b)}
                        disabled={isBusy}
                        className="btn-text"
                        style={{ color: 'var(--warning)', cursor: 'pointer' }}
                      >
                        {isBusy ? t('bookings.cancelling') : t('bookings.action.cancel')}
                      </button>
                    </>
                  )}
                  <button
                    onClick={() => onDelete(b)}
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
  )
}

export function BookingsTableHead({ actions = false }: { actions?: boolean }) {
  const t = useT()

  return (
    <thead>
      <tr>
        <th>{t('table.date')}</th><th>{t('table.time')}</th>
        <th>{t('table.service')}</th><th>{t('table.with')}</th>
        <th>{t('table.status')}</th><th>{t('table.total')}</th>
        <th style={actions ? { textAlign: 'right' } : undefined}>{actions ? t('table.actions') : undefined}</th>
      </tr>
    </thead>
  )
}
