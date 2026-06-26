import {
  addDays,
  endOfMonth,
  endOfWeek,
  isWithinRange,
  startOfMonth,
  startOfWeek,
  timeToMinutes,
  toISODate,
} from '../../utils/date'
import type { Booking } from '../../types'

export const DEFAULT_HOUR_START = 9
export const DEFAULT_HOUR_END = 18
export const HOUR_HEIGHT = 56 // px, matches CSS .slot height

export interface DashboardDelta {
  value: string
  down: boolean
}

export interface DashboardStats {
  todayCount: number
  todayDelta: DashboardDelta | null
  weekCount: number
  weekDelta: DashboardDelta | null
  monthRevenue: number
  monthRevenueDelta: DashboardDelta | null
  monthCancellations: number
  monthCancellationsDelta: DashboardDelta | null
}

export interface HourBounds {
  startHour: number
  endHour: number
}

export function formatDiff(curr: number, prev: number): DashboardDelta | null {
  const diff = curr - prev
  if (diff === 0 && curr === 0) return null
  const sign = diff > 0 ? '+' : diff < 0 ? '−' : ''
  return { value: `${sign}${Math.abs(diff)}`, down: diff < 0 }
}

export function formatMoneyDiff(curr: number, prev: number): DashboardDelta | null {
  const diff = curr - prev
  if (diff === 0 && curr === 0) return null
  const sign = diff > 0 ? '+' : diff < 0 ? '−' : ''
  return { value: `${sign}$${Math.abs(diff).toLocaleString('en-US')}`, down: diff < 0 }
}

export function calculateDashboardStats(bookings: Booking[], now = new Date()): DashboardStats {
  const active = bookings.filter((b) => b.status !== 'cancelled')
  const cancelled = bookings.filter((b) => b.status === 'cancelled')
  const confirmed = bookings.filter((b) => b.status === 'confirmed')

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

  const todayCount = active.filter((b) => b.dateISO === todayISO).length
  const yesterdayCount = active.filter((b) => b.dateISO === yesterdayISO).length

  const weekCount = active.filter((b) => isWithinRange(b.dateISO, weekStart, weekEnd)).length
  const lastWeekCount = active.filter((b) =>
    isWithinRange(b.dateISO, lastWeekStart, lastWeekEnd),
  ).length

  const monthRevenue = confirmed
    .filter((b) => isWithinRange(b.dateISO, monthStart, monthEnd))
    .reduce((sum, b) => sum + (Number(b.total) || 0), 0)
  const lastMonthRevenue = confirmed
    .filter((b) => isWithinRange(b.dateISO, lastMonthStart, lastMonthEnd))
    .reduce((sum, b) => sum + (Number(b.total) || 0), 0)

  const monthCancellations = cancelled.filter((b) =>
    isWithinRange(b.dateISO, monthStart, monthEnd),
  ).length
  const lastMonthCancellations = cancelled.filter((b) =>
    isWithinRange(b.dateISO, lastMonthStart, lastMonthEnd),
  ).length

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
}

export function groupWeekEvents(
  bookings: Booking[],
  weekAnchor: Date,
  days: Date[],
): Record<number, Booking[]> {
  const result: Record<number, Booking[]> = {}
  const weekStart = startOfWeek(weekAnchor)
  const weekEnd = endOfWeek(weekAnchor)

  for (const b of bookings) {
    if (b.status === 'cancelled') continue
    if (!isWithinRange(b.dateISO, weekStart, weekEnd)) continue

    const idx = days.findIndex((d) => toISODate(d) === b.dateISO)
    if (idx < 0) continue
    if (!result[idx]) result[idx] = []
    result[idx].push(b)
  }

  return result
}

export function getHourBounds(weekEventsByDay: Record<number, Booking[]>): HourBounds {
  let startHour = DEFAULT_HOUR_START
  let endHour = DEFAULT_HOUR_END

  for (const dayBookings of Object.values(weekEventsByDay)) {
    for (const b of dayBookings) {
      const startMin = timeToMinutes(b.time || '00:00')
      const endMin = b.endTime ? timeToMinutes(b.endTime) : startMin + (Number(b.durationMin) || 60)
      startHour = Math.min(startHour, Math.floor(startMin / 60))
      endHour = Math.max(endHour, Math.ceil(endMin / 60))
    }
  }

  return {
    startHour: Math.max(0, startHour),
    endHour: Math.min(24, endHour),
  }
}

export function getHours(bounds: HourBounds): string[] {
  return Array.from(
    { length: bounds.endHour - bounds.startHour },
    (_, i) => `${String(bounds.startHour + i).padStart(2, '0')}:00`,
  )
}

export function getEventGeometry(
  b: Booking,
  hourBounds: HourBounds,
): { top: number; height: number } {
  const startMin = timeToMinutes(b.time || '00:00')
  const endMin = b.endTime ? timeToMinutes(b.endTime) : startMin + (Number(b.durationMin) || 60)
  const hourStartMin = hourBounds.startHour * 60
  const top = ((startMin - hourStartMin) / 60) * HOUR_HEIGHT
  const height = Math.max(24, ((endMin - startMin) / 60) * HOUR_HEIGHT)
  return { top, height }
}

export function getUpcomingBookings(bookings: Booking[], now = new Date()): Booking[] {
  const todayISO = toISODate(now)
  return bookings
    .filter((b) => b.dateISO >= todayISO && b.status !== 'cancelled')
    .sort((a, b) => {
      const byDate = (a.dateISO || '').localeCompare(b.dateISO || '')
      if (byDate !== 0) return byDate
      return (a.time || '').localeCompare(b.time || '')
    })
    .slice(0, 5)
}
