import { describe, expect, it } from 'vitest'
import {
  calculateDashboardStats,
  getEventGeometry,
  getHourBounds,
  getHours,
  getUpcomingBookings,
  groupWeekEvents,
} from '../src/pages/dashboard/dashboardUtils.ts'
import { addDays, startOfWeek } from '../src/utils/date.ts'

const baseBooking = {
  id: 1,
  providerId: 1,
  customerId: 1,
  dateISO: '2099-06-16',
  time: '10:00',
  endTime: '11:00',
  durationMin: 60,
  service: 'Lesson',
  total: 100,
  status: 'confirmed',
  withName: 'Client',
  initials: 'C',
  customerEmail: 'client@example.com',
  customerPhone: null,
  notes: null,
  createdAt: '2099-01-01',
}

describe('dashboardUtils', () => {
  it('calculates dashboard stats for day, week, revenue and cancellations', () => {
    const now = new Date(2099, 5, 16, 12, 0)
    const bookings = [
      { ...baseBooking, id: 1, dateISO: '2099-06-16', status: 'confirmed', total: 100 },
      { ...baseBooking, id: 2, dateISO: '2099-06-17', status: 'confirmed', total: 200 },
      { ...baseBooking, id: 3, dateISO: '2099-06-18', status: 'cancelled', total: 300 },
      { ...baseBooking, id: 4, dateISO: '2099-06-09', status: 'confirmed', total: 50 },
    ]

    const stats = calculateDashboardStats(bookings, now)

    expect(stats.todayCount).toBe(1)
    expect(stats.weekCount).toBe(2)
    expect(stats.monthRevenue).toBe(350)
    expect(stats.monthCancellations).toBe(1)
  })

  it('groups active week events by day index and skips cancelled bookings', () => {
    const weekAnchor = new Date(2099, 5, 16)
    const weekStart = startOfWeek(weekAnchor)
    const days = Array.from({ length: 7 }, (_, i) => addDays(weekStart, i))
    const bookings = [
      { ...baseBooking, id: 1, dateISO: '2099-06-16', status: 'confirmed' },
      { ...baseBooking, id: 2, dateISO: '2099-06-16', status: 'cancelled' },
      { ...baseBooking, id: 3, dateISO: '2099-06-17', status: 'confirmed' },
    ]

    const grouped = groupWeekEvents(bookings, weekAnchor, days)

    expect(grouped[1].map(b => b.id)).toEqual([1])
    expect(grouped[2].map(b => b.id)).toEqual([3])
  })

  it('expands visible hours to include early and late bookings', () => {
    const bounds = getHourBounds({
      0: [
        { ...baseBooking, id: 1, time: '07:30', endTime: '08:30' },
        { ...baseBooking, id: 2, time: '20:00', endTime: '21:00' },
      ],
    })

    expect(bounds).toEqual({ startHour: 7, endHour: 21 })
    expect(getHours(bounds)).toContain('20:00')
  })

  it('returns event geometry in pixels relative to visible hour bounds', () => {
    const geometry = getEventGeometry(
      { ...baseBooking, time: '10:30', endTime: '12:00' },
      { startHour: 9, endHour: 18 },
    )

    expect(geometry.top).toBe(84)
    expect(geometry.height).toBe(84)
  })

  it('returns only upcoming non-cancelled bookings sorted by date and time', () => {
    const now = new Date(2099, 5, 16, 12, 0)
    const bookings = [
      { ...baseBooking, id: 1, dateISO: '2099-06-17', time: '12:00', status: 'confirmed' },
      { ...baseBooking, id: 2, dateISO: '2099-06-16', time: '09:00', status: 'confirmed' },
      { ...baseBooking, id: 3, dateISO: '2099-06-18', time: '10:00', status: 'cancelled' },
      { ...baseBooking, id: 4, dateISO: '2099-06-15', time: '10:00', status: 'confirmed' },
    ]

    expect(getUpcomingBookings(bookings, now).map(b => b.id)).toEqual([2, 1])
  })
})
