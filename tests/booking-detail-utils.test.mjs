import { describe, expect, it } from 'vitest'
import {
  formatBookingDate,
  getBookingRef,
  getBookingTimeRange,
  getStatusTone,
} from '../src/pages/booking-detail/bookingDetailUtils.ts'

const booking = {
  id: 7,
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

describe('bookingDetailUtils', () => {
  it('formats booking reference with zero padding', () => {
    expect(getBookingRef(7)).toBe('SLT-0007')
    expect(getBookingRef('42')).toBe('SLT-0042')
  })

  it('formats time range with optional end time', () => {
    expect(getBookingTimeRange(booking)).toBe('10:00 – 11:00')
    expect(getBookingTimeRange({ ...booking, endTime: undefined })).toBe('10:00')
  })

  it('maps booking status to pill tone', () => {
    expect(getStatusTone('confirmed')).toBe('success')
    expect(getStatusTone('cancelled')).toBe('danger')
    expect(getStatusTone('pending')).toBe('accent')
  })

  it('formats date and handles missing value', () => {
    expect(formatBookingDate(undefined, 'en')).toBe('')
    expect(formatBookingDate('2099-06-16', 'en')).toContain('2099')
  })
})
