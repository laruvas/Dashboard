import { Button } from '../../components/UI'
import EmptyState from '../../components/EmptyState'
import { SkeletonTableRow } from '../../components/Skeleton'
import { useT } from '../../i18n/SettingsContext'
import { BookingsTableHead } from './BookingsTable'
import type { StatusTab } from './bookingsTypes'

interface BookingsErrorProps {
  error: string
}

export function BookingsError({ error }: BookingsErrorProps) {
  return (
    <div className="mb-4" style={{
      padding: '12px 16px', border: '1px solid rgba(248,113,113,0.32)',
      background: 'rgba(248,113,113,0.12)', color: 'var(--danger)',
      borderRadius: 'var(--r-md)', fontSize: 13,
    }}>{error}</div>
  )
}

export function BookingsSkeleton() {
  return (
    <table className="table">
      <BookingsTableHead />
      <tbody>
        {Array.from({ length: 5 }, (_, i) => <SkeletonTableRow key={i} cols={7} />)}
      </tbody>
    </table>
  )
}

export function FirstRunEmptyState() {
  const t = useT()

  return (
    <EmptyState
      illustration="calendar"
      title={t('bookings.empty.first')}
      description={t('bookings.empty.first.desc')}
      action={
        <div className="flex flex-gap-2">
          <Button as="link" to="/booking">+ {t('nav.newBooking')}</Button>
          <Button as="link" to="/services" variant="ghost">{t('services.add')}</Button>
        </div>
      }
    />
  )
}

export function EmptyBookingsState({ status, query }: { status: StatusTab; query: string }) {
  const t = useT()

  if (query.trim()) {
    return <EmptyState illustration="search" title={t('bookings.search.empty')} />
  }

  const titleMap: Record<StatusTab, string> = {
    upcoming: t('bookings.empty.upcoming'),
    past: t('bookings.empty.past'),
    cancelled: t('bookings.empty.cancelled'),
  }
  const descMap: Record<StatusTab, string> = {
    upcoming: t('bookings.empty.upcoming.desc'),
    past: t('bookings.empty.past.desc'),
    cancelled: t('bookings.empty.cancelled.desc'),
  }

  return (
    <EmptyState
      illustration="calendar"
      title={titleMap[status]}
      description={descMap[status]}
      action={status === 'upcoming'
        ? <Button as="link" to="/booking">+ {t('nav.newBooking')}</Button>
        : undefined}
    />
  )
}
