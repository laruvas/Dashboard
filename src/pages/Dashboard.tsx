import { useEffect, useMemo, useState } from 'react'
import { Link } from 'react-router-dom'
import { Button, Stat, Pill, Avatar } from '../components/UI'
import EmptyState from '../components/EmptyState'
import { SkeletonStat, SkeletonTableRow, useDelayedFlag } from '../components/Skeleton'
import { listBookings } from '../data/bookingsApi'
import { useT, useSettings } from '../i18n/SettingsContext'
import { useAuth } from '../i18n/AuthContext'
import {
  toISODate, startOfWeek, endOfWeek, startOfMonth, endOfMonth,
  addDays, isSameDay, isWithinRange, timeToMinutes,
} from '../utils/date'
import type { Booking, Lang } from '../types'

/* ============== Constants ============== */

// Default visible window: 09:00-18:00. The actual window can extend if there are
// bookings outside it — see `hourBounds` in the component below.
const DEFAULT_HOUR_START = 9
const DEFAULT_HOUR_END = 18
const HOUR_HEIGHT = 56 // px, matches CSS .slot height

const DOW_LABELS: Record<Lang, string[]> = {
  en: ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'],
  ru: ['ПН', 'ВТ', 'СР', 'ЧТ', 'ПТ', 'СБ', 'ВС'],
}

/* ============== Helpers ============== */

function formatDiff(curr: number, prev: number): { value: string; down: boolean } | null {
  const diff = curr - prev
  if (diff === 0 && curr === 0) return null
  const sign = diff > 0 ? '+' : diff < 0 ? '−' : ''
  return { value: `${sign}${Math.abs(diff)}`, down: diff < 0 }
}

function formatMoneyDiff(curr: number, prev: number): { value: string; down: boolean } | null {
  const diff = curr - prev
  if (diff === 0 && curr === 0) return null
  const sign = diff > 0 ? '+' : diff < 0 ? '−' : ''
  return { value: `${sign}$${Math.abs(diff).toLocaleString('en-US')}`, down: diff < 0 }
}

/* ============== Component ============== */

export default function Dashboard() {
  const t = useT()
  const { lang } = useSettings()
  const { user } = useAuth()
  const userId = user?.id
  // Greeting prefers displayName (e.g. "Anna"), falls back to full name's first word.
  const greetingName = user?.displayName || user?.name?.split(' ')[0] || ''

  const [rawBookings, setRawBookings] = useState<Booking[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  // Current week shown in the week-calendar (mutable via prev/today/next)
  const [weekAnchor, setWeekAnchor] = useState<Date>(() => new Date())

  useEffect(() => {
    let mounted = true
    listBookings()
      .then((data) => { if (mounted) { setRawBookings(data); setError(null) } })
      .catch(() => { if (mounted) setError(t('dashboard.errorServer')) })
      .finally(() => { if (mounted) setLoading(false) })
    return () => { mounted = false }
  }, [t])

  // Dashboard is the "specialist panel": only show bookings where the current
  // user is the PROVIDER. Customer-side bookings live in /bookings under
  // the "Mine" scope.
  const bookings = useMemo(
    () => userId == null ? [] : rawBookings.filter(b => Number(b.providerId) === userId),
    [rawBookings, userId],
  )

  /* ============== Stats (memoized) ============== */

  const stats = useMemo(() => {
    const active = bookings.filter(b => b.status !== 'cancelled')
    const cancelled = bookings.filter(b => b.status === 'cancelled')
    const confirmed = bookings.filter(b => b.status === 'confirmed')

    const now = new Date()
    const todayISO = toISODate(now)
    const yesterdayISO = toISODate(addDays(now, -1))

    const weekStart = startOfWeek(now)
    const weekEnd = endOfWeek(now)
    const lastWeekStart = addDays(weekStart, -7)
    const lastWeekEnd = addDays(weekEnd, -7)

    const monthStart = startOfMonth(now)
    const monthEnd = endOfMonth(now)
    const lastMonthEnd = new Date(monthStart.getFullYear(), monthStart.getMonth(), 0, 23, 59, 59, 999)
    const lastMonthStart = startOfMonth(lastMonthEnd)

    const todayCount = active.filter(b => b.dateISO === todayISO).length
    const yesterdayCount = active.filter(b => b.dateISO === yesterdayISO).length

    const weekCount = active.filter(b => isWithinRange(b.dateISO, weekStart, weekEnd)).length
    const lastWeekCount = active.filter(b => isWithinRange(b.dateISO, lastWeekStart, lastWeekEnd)).length

    const monthRevenue = confirmed
      .filter(b => isWithinRange(b.dateISO, monthStart, monthEnd))
      .reduce((sum, b) => sum + (Number(b.total) || 0), 0)
    const lastMonthRevenue = confirmed
      .filter(b => isWithinRange(b.dateISO, lastMonthStart, lastMonthEnd))
      .reduce((sum, b) => sum + (Number(b.total) || 0), 0)

    const monthCancellations = cancelled
      .filter(b => isWithinRange(b.dateISO, monthStart, monthEnd))
      .length
    const lastMonthCancellations = cancelled
      .filter(b => isWithinRange(b.dateISO, lastMonthStart, lastMonthEnd))
      .length

    return {
      todayCount,
      todayDelta: formatDiff(todayCount, yesterdayCount),
      weekCount,
      weekDelta: formatDiff(weekCount, lastWeekCount),
      monthRevenue,
      monthRevenueDelta: formatMoneyDiff(monthRevenue, lastMonthRevenue),
      monthCancellations,
      monthCancellationsDelta: formatDiff(monthCancellations, lastMonthCancellations),
    }
  }, [bookings])

  /* ============== Week calendar ============== */

  const weekStart = useMemo(() => startOfWeek(weekAnchor), [weekAnchor])
  const days = useMemo(() => Array.from({ length: 7 }, (_, i) => addDays(weekStart, i)), [weekStart])

  /** Events grouped by day index (0=Mon..6=Sun). */
  const weekEventsByDay = useMemo(() => {
    const result: Record<number, Booking[]> = {}
    const weekEnd = endOfWeek(weekAnchor)
    for (const b of bookings) {
      if (b.status === 'cancelled') continue
      if (!isWithinRange(b.dateISO, weekStart, weekEnd)) continue
      // Find day index
      const idx = days.findIndex(d => toISODate(d) === b.dateISO)
      if (idx < 0) continue
      if (!result[idx]) result[idx] = []
      result[idx].push(b)
    }
    return result
  }, [bookings, weekAnchor, weekStart, days])

  /**
   * Adaptive hour range: starts at 09:00 / ends at 18:00 by default, but expands
   * to include any bookings outside that window (early-morning at 07:00, evening
   * 21:00, etc.) so events are never clipped off the calendar.
   */
  const hourBounds = useMemo(() => {
    let startHour = DEFAULT_HOUR_START
    let endHour = DEFAULT_HOUR_END
    for (const dayBookings of Object.values(weekEventsByDay)) {
      for (const b of dayBookings) {
        const startMin = timeToMinutes(b.time || '00:00')
        const endMin = b.endTime
          ? timeToMinutes(b.endTime)
          : startMin + (Number(b.durationMin) || 60)
        startHour = Math.min(startHour, Math.floor(startMin / 60))
        endHour   = Math.max(endHour,   Math.ceil(endMin / 60))
      }
    }
    // Clamp to a sane 24-hour window.
    startHour = Math.max(0, startHour)
    endHour   = Math.min(24, endHour)
    return { startHour, endHour }
  }, [weekEventsByDay])

  const hours = useMemo(() => Array.from(
    { length: hourBounds.endHour - hourBounds.startHour },
    (_, i) => `${String(hourBounds.startHour + i).padStart(2, '0')}:00`,
  ), [hourBounds])

  /** Convert a booking's start/end time into pixel top/height for the week column. */
  const eventGeometry = (b: Booking) => {
    const startMin = timeToMinutes(b.time || '00:00')
    const endMin = b.endTime
      ? timeToMinutes(b.endTime)
      : startMin + (Number(b.durationMin) || 60)
    const hourStartMin = hourBounds.startHour * 60
    const top = ((startMin - hourStartMin) / 60) * HOUR_HEIGHT
    const height = Math.max(24, ((endMin - startMin) / 60) * HOUR_HEIGHT)
    return { top, height }
  }

  /* ============== Upcoming ============== */

  const upcoming = useMemo(() => {
    const todayISO = toISODate(new Date())
    return bookings
      .filter(b => b.dateISO >= todayISO && b.status !== 'cancelled')
      .sort((a, b) => {
        const byDate = (a.dateISO || '').localeCompare(b.dateISO || '')
        if (byDate !== 0) return byDate
        return (a.time || '').localeCompare(b.time || '')
      })
      .slice(0, 5)
  }, [bookings])

  /* ============== Render helpers ============== */

  const today = new Date()
  const isCurrentWeek = isSameDay(startOfWeek(today), weekStart)
  const showSkeleton = useDelayedFlag(loading)

  const goPrevWeek = () => setWeekAnchor(addDays(weekAnchor, -7))
  const goNextWeek = () => setWeekAnchor(addDays(weekAnchor, 7))
  const goToday = () => setWeekAnchor(new Date())

  const renderDelta = (d: ReturnType<typeof formatDiff>, key: 'vsYesterday' | 'vsLastWeek' | 'vsLastMonth') => {
    if (!d) return undefined
    return t(`dashboard.stat.delta.${key}`, { n: d.value })
  }

  return (
    <>
      <div className="mb-6">
        <h1>{t('dashboard.greeting', { name: greetingName })}</h1>
        <p className="subtitle mt-2">{t('dashboard.subtitle', { n: stats.todayCount })}</p>
      </div>

      {error && (
        <div className="card mb-6" style={{ borderColor: 'rgba(248,113,113,0.32)', color: 'var(--danger)' }}>
          {error}
        </div>
      )}

      <div className="grid grid-4 mb-8">
        {loading && showSkeleton ? (
          <>
            <SkeletonStat /><SkeletonStat /><SkeletonStat /><SkeletonStat />
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
              // For cancellations, "more" is bad — flip the colour intuitively
              down={stats.monthCancellationsDelta ? !stats.monthCancellationsDelta.down && stats.monthCancellationsDelta.value !== '0' : undefined}
            />
          </>
        )}
      </div>

      <div className="flex-between mb-4">
        <h2>{t('dashboard.thisWeek')}</h2>
        <div className="flex flex-gap-2">
          <Button variant="ghost" size="sm" onClick={goPrevWeek}>{t('dashboard.prev')}</Button>
          <Button variant="ghost" size="sm" onClick={goToday} disabled={isCurrentWeek}>{t('dashboard.today')}</Button>
          <Button variant="ghost" size="sm" onClick={goNextWeek}>{t('dashboard.next')}</Button>
        </div>
      </div>

      <div className="week mb-8">
        <div className="week-head">
          <div className="col" />
          {days.map((d, i) => (
            <div className={`col ${isSameDay(d, today) ? 'today' : ''}`} key={i}>
              {DOW_LABELS[lang][i]}
              <div className="day-num">{d.getDate()}</div>
            </div>
          ))}
        </div>
        <div className="week-body">
          <div className="hour-col">
            {hours.map(h => <div className="hour" key={h}>{h}</div>)}
          </div>
          {days.map((_, i) => (
            <div className="day-col" key={i}>
              {hours.map((_, j) => <div className="slot" key={j} />)}
              {(weekEventsByDay[i] || []).map((b) => {
                const { top, height } = eventGeometry(b)
                return (
                  <Link
                    to={`/bookings/${b.id}`}
                    key={b.id}
                    className="event"
                    style={{ top, height, textDecoration: 'none' }}
                  >
                    <div className="title">{b.service}</div>
                    <div className="time">
                      {b.time}{b.endTime ? ` – ${b.endTime}` : ''}
                    </div>
                  </Link>
                )
              })}
            </div>
          ))}
        </div>
      </div>

      <h2 className="mb-4">{t('dashboard.upcomingNext')}</h2>

      {!error && loading && showSkeleton && (
        <table className="table">
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
          <tbody>
            {Array.from({ length: 3 }, (_, i) => <SkeletonTableRow key={i} cols={6} />)}
          </tbody>
        </table>
      )}

      {!error && !loading && upcoming.length === 0 && (
        <EmptyState
          illustration="calendar"
          title={t('dashboard.empty')}
          action={<Button as="link" to="/booking">+ {t('nav.newBooking')}</Button>}
        />
      )}

      {!error && !loading && upcoming.length > 0 && (
        <table className="table">
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
          <tbody>
            {upcoming.map((b) => (
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
                <td><Pill tone={b.status === 'confirmed' ? 'success' : 'accent'}>{t(`status.${b.status}`)}</Pill></td>
                <td><Link to={`/bookings/${b.id}`} className="btn-text">{t('action.view.arrow')}</Link></td>
              </tr>
            ))}
          </tbody>
        </table>
      )}
    </>
  )
}
