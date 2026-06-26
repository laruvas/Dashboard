import { useEffect, useMemo, useState } from 'react'
import { listBookings } from '../data/bookingsApi'
import { useT } from '../i18n/SettingsContext'
import { useAuth } from '../i18n/AuthContext'
import { addDays, isSameDay, startOfWeek } from '../utils/date'
import type { Booking } from '../types'
import DashboardHeader from './dashboard/DashboardHeader'
import DashboardStatsGrid from './dashboard/DashboardStatsGrid'
import WeekCalendar from './dashboard/WeekCalendar'
import UpcomingBookings from './dashboard/UpcomingBookings'
import {
  calculateDashboardStats,
  getHourBounds,
  getHours,
  getUpcomingBookings,
  groupWeekEvents,
} from './dashboard/dashboardUtils'
import { useDelayedFlag } from '../components/Skeleton'

export default function Dashboard() {
  const t = useT()
  const { user } = useAuth()
  const userId = user?.id
  // Greeting prefers displayName (e.g. "Anna"), falls back to full name's first word.
  const greetingName = user?.displayName || user?.name?.split(' ')[0] || ''

  const [rawBookings, setRawBookings] = useState<Booking[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  // Current week shown in the week-calendar (mutable via prev/today/next).
  const [weekAnchor, setWeekAnchor] = useState<Date>(() => new Date())

  useEffect(() => {
    let mounted = true
    listBookings()
      .then((data) => {
        if (mounted) {
          setRawBookings(data)
          setError(null)
        }
      })
      .catch(() => {
        if (mounted) setError(t('dashboard.errorServer'))
      })
      .finally(() => {
        if (mounted) setLoading(false)
      })
    return () => {
      mounted = false
    }
  }, [t])

  // Dashboard is the "specialist panel": only show bookings where the current
  // user is the PROVIDER. Customer-side bookings live in /bookings under
  // the "Mine" scope.
  const bookings = useMemo(
    () => (userId == null ? [] : rawBookings.filter((b) => Number(b.providerId) === userId)),
    [rawBookings, userId],
  )

  const stats = useMemo(() => calculateDashboardStats(bookings), [bookings])

  const weekStart = useMemo(() => startOfWeek(weekAnchor), [weekAnchor])
  const days = useMemo(
    () => Array.from({ length: 7 }, (_, i) => addDays(weekStart, i)),
    [weekStart],
  )
  const weekEventsByDay = useMemo(
    () => groupWeekEvents(bookings, weekAnchor, days),
    [bookings, weekAnchor, days],
  )
  const hourBounds = useMemo(() => getHourBounds(weekEventsByDay), [weekEventsByDay])
  const hours = useMemo(() => getHours(hourBounds), [hourBounds])
  const upcoming = useMemo(() => getUpcomingBookings(bookings), [bookings])

  const today = new Date()
  const isCurrentWeek = isSameDay(startOfWeek(today), weekStart)
  const showSkeleton = useDelayedFlag(loading)

  return (
    <>
      <DashboardHeader greetingName={greetingName} todayCount={stats.todayCount} />

      {error && (
        <div
          className="card mb-6"
          style={{ borderColor: 'rgba(248,113,113,0.32)', color: 'var(--danger)' }}
        >
          {error}
        </div>
      )}

      <DashboardStatsGrid stats={stats} loading={loading} showSkeleton={showSkeleton} />

      <WeekCalendar
        days={days}
        hours={hours}
        today={today}
        isCurrentWeek={isCurrentWeek}
        hourBounds={hourBounds}
        weekEventsByDay={weekEventsByDay}
        onPrevWeek={() => setWeekAnchor(addDays(weekAnchor, -7))}
        onToday={() => setWeekAnchor(new Date())}
        onNextWeek={() => setWeekAnchor(addDays(weekAnchor, 7))}
      />

      <UpcomingBookings
        bookings={upcoming}
        loading={loading}
        error={error}
        showSkeleton={showSkeleton}
      />
    </>
  )
}
