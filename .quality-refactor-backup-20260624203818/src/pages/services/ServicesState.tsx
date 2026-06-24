import { Button } from '../../components/UI'
import EmptyState from '../../components/EmptyState'
import { SkeletonCardGrid } from '../../components/Skeleton'
import { useT } from '../../i18n/SettingsContext'

export function ServicesError({ error }: { error: string }) {
  return (
    <div className="card" style={{ borderColor: 'rgba(248,113,113,0.32)', color: 'var(--danger)' }}>
      {error}
    </div>
  )
}

export function ServicesSkeleton() {
  return <SkeletonCardGrid />
}

export function EmptyServicesState({ onCreate }: { onCreate: () => void }) {
  const t = useT()

  return (
    <EmptyState
      illustration="services"
      title={t('services.empty')}
      action={<Button onClick={onCreate}>{t('services.add')}</Button>}
    />
  )
}
