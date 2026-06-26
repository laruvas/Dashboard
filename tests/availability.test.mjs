// Unit tests for scripts/availability.mjs — pure slot-calc helpers.

import { describe, it, expect } from 'vitest'
import {
  hhmmToMin,
  minToHHMM,
  normalizeWorkingHours,
  dowKeyFromISO,
  formatYMD,
  calculateSlots,
  DEFAULT_WORKING_HOURS,
} from '../scripts/availability.mjs'

describe('hhmmToMin', () => {
  it('converts simple HH:MM to minutes since midnight', () => {
    expect(hhmmToMin('00:00')).toBe(0)
    expect(hhmmToMin('09:00')).toBe(540)
    expect(hhmmToMin('18:30')).toBe(1110)
    expect(hhmmToMin('23:59')).toBe(1439)
  })

  it('returns NaN for garbage input', () => {
    expect(Number.isNaN(hhmmToMin('foo'))).toBe(true)
    expect(Number.isNaN(hhmmToMin(''))).toBe(true)
  })
})

describe('minToHHMM', () => {
  it('round-trips with hhmmToMin', () => {
    for (const t of ['00:00', '09:00', '13:37', '23:59']) {
      expect(minToHHMM(hhmmToMin(t))).toBe(t)
    }
  })

  it('pads single-digit hours and minutes', () => {
    expect(minToHHMM(0)).toBe('00:00')
    expect(minToHHMM(65)).toBe('01:05')
  })

  it('wraps modulo 24 hours', () => {
    expect(minToHHMM(25 * 60)).toBe('01:00')
  })
})

describe('normalizeWorkingHours', () => {
  it('returns defaults for missing/non-object input', () => {
    expect(normalizeWorkingHours(null)).toEqual(DEFAULT_WORKING_HOURS)
    expect(normalizeWorkingHours(undefined)).toEqual(DEFAULT_WORKING_HOURS)
    expect(normalizeWorkingHours('garbage')).toEqual(DEFAULT_WORKING_HOURS)
  })

  it('expands a legacy flat { start, end } to Mon-Fri', () => {
    const out = normalizeWorkingHours({ start: '10:00', end: '16:00' })
    expect(Object.keys(out).sort()).toEqual(['fri', 'mon', 'thu', 'tue', 'wed'])
    for (const k of Object.keys(out)) {
      expect(out[k]).toEqual({ start: '10:00', end: '16:00' })
    }
  })

  it('passes through a per-day object', () => {
    const wh = { mon: { start: '08:00', end: '12:00' }, sat: { start: '10:00', end: '14:00' } }
    expect(normalizeWorkingHours(wh)).toBe(wh)
  })

  it('returns defaults when an object has no per-day keys', () => {
    expect(normalizeWorkingHours({})).toEqual(DEFAULT_WORKING_HOURS)
  })
})

describe('dowKeyFromISO', () => {
  it('maps YYYY-MM-DD to mon..sun keys', () => {
    expect(dowKeyFromISO('2024-01-01')).toBe('mon')
    expect(dowKeyFromISO('2024-01-02')).toBe('tue')
    expect(dowKeyFromISO('2024-01-03')).toBe('wed')
    expect(dowKeyFromISO('2024-01-04')).toBe('thu')
    expect(dowKeyFromISO('2024-01-05')).toBe('fri')
    expect(dowKeyFromISO('2024-01-06')).toBe('sat')
    expect(dowKeyFromISO('2024-01-07')).toBe('sun')
  })
})

describe('formatYMD', () => {
  it('formats a Date as local YYYY-MM-DD with zero-padding', () => {
    expect(formatYMD(new Date(2024, 0, 5))).toBe('2024-01-05')
    expect(formatYMD(new Date(2024, 11, 31))).toBe('2024-12-31')
  })
})

describe('calculateSlots', () => {
  const workday = { start: '09:00', end: '18:00' }
  const farFuture = '2099-06-15'

  it('returns [] when the provider is closed that day', () => {
    const slots = calculateSlots({
      window: null,
      blocking: [],
      now: new Date(),
      dateISO: farFuture,
      duration: 60,
    })
    expect(slots).toEqual([])
  })

  it('returns [] for non-positive duration', () => {
    const slots = calculateSlots({
      window: workday,
      blocking: [],
      now: new Date(),
      dateISO: farFuture,
      duration: 0,
    })
    expect(slots).toEqual([])
  })

  it('emits one slot per step within the window (60-min duration, 60-min step)', () => {
    const slots = calculateSlots({
      window: workday,
      blocking: [],
      now: new Date(),
      dateISO: farFuture,
      duration: 60,
    })
    expect(slots.map((s) => s.time)).toEqual([
      '09:00',
      '10:00',
      '11:00',
      '12:00',
      '13:00',
      '14:00',
      '15:00',
      '16:00',
      '17:00',
    ])
    expect(slots.every((s) => s.available)).toBe(true)
  })

  it('drops slots that cannot fit the full duration', () => {
    const slots = calculateSlots({
      window: workday,
      blocking: [],
      now: new Date(),
      dateISO: farFuture,
      duration: 120,
    })
    expect(slots.map((s) => s.time)).toEqual([
      '09:00',
      '10:00',
      '11:00',
      '12:00',
      '13:00',
      '14:00',
      '15:00',
      '16:00',
    ])
  })

  it('marks slots as unavailable when they overlap a blocking booking', () => {
    const slots = calculateSlots({
      window: workday,
      blocking: [[10 * 60, 11 * 60]],
      now: new Date(),
      dateISO: farFuture,
      duration: 60,
    })
    const ten = slots.find((s) => s.time === '10:00')
    const nine = slots.find((s) => s.time === '09:00')
    const eleven = slots.find((s) => s.time === '11:00')
    expect(ten.available).toBe(false)
    expect(nine.available).toBe(true)
    expect(eleven.available).toBe(true)
  })

  it('treats overlapping intervals correctly (half-open [start, end))', () => {
    const slots = calculateSlots({
      window: workday,
      blocking: [[10 * 60 + 30, 11 * 60 + 30]],
      now: new Date(),
      dateISO: farFuture,
      duration: 60,
    })
    expect(slots.find((s) => s.time === '10:00').available).toBe(false)
    expect(slots.find((s) => s.time === '11:00').available).toBe(false)
    expect(slots.find((s) => s.time === '12:00').available).toBe(true)
  })

  it('blocks slots earlier than now + minNoticeMin on the queried day', () => {
    const now = new Date(2099, 5, 15, 10, 0, 0)
    const slots = calculateSlots({
      window: workday,
      blocking: [],
      now,
      dateISO: '2099-06-15',
      duration: 60,
      minNoticeMin: 60,
    })
    const nine = slots.find((s) => s.time === '09:00')
    const ten = slots.find((s) => s.time === '10:00')
    const eleven = slots.find((s) => s.time === '11:00')
    expect(nine.available).toBe(false)
    expect(ten.available).toBe(false)
    expect(eleven.available).toBe(true)
  })

  it('does NOT apply the same-day cutoff when the date is in the future', () => {
    const now = new Date(2099, 5, 15, 10, 0, 0)
    const slots = calculateSlots({
      window: workday,
      blocking: [],
      now,
      dateISO: '2099-06-16',
      duration: 60,
      minNoticeMin: 60,
    })
    expect(slots.every((s) => s.available)).toBe(true)
  })
})
