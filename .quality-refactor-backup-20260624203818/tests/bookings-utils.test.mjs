import { describe, expect, it } from 'vitest'
import {
  addMinutesHHMM,
  annotateBookings,
  filterBookings,
  formatDateShort,
  groupBookingsByStatus,
  sortBookings,
} from '../src/pages/bookings/bookingsUtils.ts'

const baseBooking = {
  id: '1',
  providerId: 1,
  customerId: 1,
  dateISO: '2099-06-16',
  time: '10:00',
  endTime: '11:00',
  durationMin: 60,
  service: 'English lesson',
  total: 100,
  status: 'confirmed',
  withName: 'Anna Smith',
  initials: 'AS',
  customerEmail: 'anna@example.com',
  customerPhone: null,
  notes: null,
  createdAt: '2099-01-01',
}

describe('bookingsUtils', () => {
  it('sorts bookings by date and time', () => {
    const sorted = sortBookings([
      { ...baseBooking, id: '3', dateISO: '2099-06-17', time: '09:00' },
      { ...baseBooking, id: '1', dateISO: '2099-06-16', time: '11:00' },
      { ...baseBooking, id: '2', dateISO: '2099-06-16', time: '10:00' },
    ])

    expect(sorted.map(b => b.id)).toEqual(['2', '1', '3'])
  })

  it('groups bookings into upcoming, past and cancelled', () => {
    const annotated = annotateBookings([
      { ...baseBooking, id: '1', dateISO: '2099-06-16', status: 'confirmed' },
      { ...baseBooking, id: '2', dateISO: '2099-06-15', status: 'confirmed' },
      { ...baseBooking, id: '3', dateISO: '2099-06-17', status: 'cancelled' },
    ])

    const groups = groupBookingsByStatus(annotated, '2099-06-16')

    expect(groups.upcoming.map(x => x.b.id)).toEqual(['1'])
    expect(groups.past.map(x => x.b.id)).toEqual(['2'])
    expect(groups.cancelled.map(x => x.b.id)).toEqual(['3'])
  })

  it('filters visible bookings by customer, service, email or date', () => {
    const annotated = annotateBookings([
      { ...baseBooking, id: '1', service: 'English lesson', withName: 'Anna Smith' },
      { ...baseBooking, id: '2', service: 'Math lesson', withName: 'Bob Brown', customerEmail: 'bob@example.com' },
    ])
    const groups = { upcoming: annotated, past: [], cancelled: [] }

    expect(filterBookings(groups, 'upcoming', 'math').map(x => x.b.id)).toEqual(['2'])
    expect(filterBookings(groups, 'upcoming', 'anna').map(x => x.b.id)).toEqual(['1'])
    expect(filterBookings(groups, 'upcoming', 'bob@example.com').map(x => x.b.id)).toEqual(['2'])
  })

  it('adds minutes to HH:MM time', () => {
    expect(addMinutesHHMM('10:30', 90)).toBe('12:00')
    expect(addMinutesHHMM('23:30', 60)).toBe('00:30')
  })

  it('formats short dates and handles missing value', () => {
    expect(formatDateShort(undefined, 'en')).toBe('—')
    expect(formatDateShort('2099-06-16', 'en')).toMatch(/Jun|16/)
  })
})
