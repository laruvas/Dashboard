import { Link } from 'react-router-dom'
import { Button, Pill, Avatar } from '../../components/UI'
import EmptyState from '../../components/EmptyState'
import { SkeletonTableRow } from '../../components/Skeleton'
import { useT } from '../../i18n/SettingsContext'
import type { Booking } from '../../types'

interface UpcomingBookingsProps {
  bookings: Booking[]
  loading: boolean
  error: string | null
  showSkeleton: boolean
}

export default function UpcomingBookings({
  bookings,
  loading,
  error,
  showSkeleton,
}: UpcomingBookingsProps) {
  const t = useT()

  return (
    <>
      <h2 className="mb-4">{t('dashboard.upcomingNext')}</h2>

      {!error && loading && showSkeleton && (
        <table className="table">
          <TableHead />
          <tbody>
            {Array.from({ length: 3 }, (_, i) => (
              <SkeletonTableRow key={i} cols={6} />
            ))}
          </tbody>
        </table>
      )}

      {!error && !loading && bookings.length === 0 && (
        <EmptyState
          illustration="calendar"
          title={t('dashboard.empty')}
          action={
            <Button as="link" to="/booking">
              + {t('nav.newBooking')}
            </Button>
          }
        />
      )}

      {!error && !loading && bookings.length > 0 && (
        <table className="table">
          <TableHead />
          <tbody>
            {bookings.map((b) => (
              <tr key={b.id}>
                <td className="mono">{b.dateISO}</td>
                <td className="mono">{b.time}</td>
                <td>{b.service}</td>
                <td>
                  <div className="flex flex-gap-2" style={{ alignItems: 'center' }}>
                    <Avatar initials={b.initials || '?'} size={24} />
                    {b.withName || '—'}
                  </div>
                </td>
                <td>
                  <Pill tone={b.status === 'confirmed' ? 'success' : 'accent'}>
                    {t(`status.${b.status}`)}
                  </Pill>
                </td>
                <td>
                  <Link to={`/bookings/${b.id}`} className="btn-text">
                    {t('action.view.arrow')}
                  </Link>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      )}
    </>
  )
}

function TableHead() {
  const t = useT()

  return (
    <thead>
      <tr>
        <th>{t('table.date')}</th>
        <th>{t('table.time')}</th>
        <th>{t('table.service')}</th>
        <th>{t('table.with')}</th>
        <th>{t('table.status')}</th>
        <th />
      </tr>
    </thead>
  )
}
