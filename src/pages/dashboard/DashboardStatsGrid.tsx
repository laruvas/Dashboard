import { Stat } from '../../components/UI'
import { SkeletonStat } from '../../components/Skeleton'
import { useT } from '../../i18n/SettingsContext'
import type { DashboardDelta, DashboardStats } from './dashboardUtils'

interface DashboardStatsGridProps {
  stats: DashboardStats
  loading: boolean
  showSkeleton: boolean
}

export default function DashboardStatsGrid({
  stats,
  loading,
  showSkeleton,
}: DashboardStatsGridProps) {
  const t = useT()

  const renderDelta = (
    d: DashboardDelta | null,
    key: 'vsYesterday' | 'vsLastWeek' | 'vsLastMonth',
  ) => {
    if (!d) return undefined
    return t(`dashboard.stat.delta.${key}`, { n: d.value })
  }

  return (
    <div className="grid grid-4 mb-8">
      {loading && showSkeleton ? (
        <>
          <SkeletonStat />
          <SkeletonStat />
          <SkeletonStat />
          <SkeletonStat />
        </>
      ) : (
        <>
          <Stat
            label={t('dashboard.stat.today')}
            value={loading ? '—' : stats.todayCount}
            delta={renderDelta(stats.todayDelta, 'vsYesterday')}
            down={stats.todayDelta?.down}
          />
          <Stat
            label={t('dashboard.stat.week')}
            value={loading ? '—' : stats.weekCount}
            delta={renderDelta(stats.weekDelta, 'vsLastWeek')}
            down={stats.weekDelta?.down}
          />
          <Stat
            label={t('dashboard.stat.revenue')}
            value={loading ? '—' : `$${stats.monthRevenue.toLocaleString('en-US')}`}
            delta={renderDelta(stats.monthRevenueDelta, 'vsLastMonth')}
            down={stats.monthRevenueDelta?.down}
          />
          <Stat
            label={t('dashboard.stat.cancellations')}
            value={loading ? '—' : stats.monthCancellations}
            delta={renderDelta(stats.monthCancellationsDelta, 'vsLastMonth')}
            // For cancellations, "more" is bad — flip the colour intuitively.
            down={
              stats.monthCancellationsDelta
                ? !stats.monthCancellationsDelta.down && stats.monthCancellationsDelta.value !== '0'
                : undefined
            }
          />
        </>
      )}
    </div>
  )
}
