import EmptyState from '../../components/EmptyState'
import { Skeleton } from '../../components/Skeleton'
import { useT } from '../../i18n/SettingsContext'

export function BookingDetailSkeleton() {
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

export function BookingDetailNotFound({ title, onBack }: { title: string; onBack: () => void }) {
  const t = useT()

  return (
    <>
      <button onClick={onBack} className="btn-text" style={{ fontSize: 13, cursor: 'pointer' }}>
        {t('bookings.detail.backToList')}
      </button>
      <EmptyState illustration="calendar" title={title} />
    </>
  )
}
