import { describe, expect, it } from 'vitest'
import {
  DEFAULT_WORKING_HOURS,
  getInitialProfileForm,
  getInitials,
  normalizeWorkingHours,
} from '../src/pages/profile/profileUtils.ts'
import { makeUser } from './helpers/factories.mjs'

describe('profileUtils', () => {
  it('returns default working hours for missing value', () => {
    expect(normalizeWorkingHours(undefined)).toEqual(DEFAULT_WORKING_HOURS)
  })

  it('expands legacy flat working hours to weekdays', () => {
    const normalized = normalizeWorkingHours({ start: '10:00', end: '17:00' })

    expect(normalized.mon).toEqual({ start: '10:00', end: '17:00' })
    expect(normalized.fri).toEqual({ start: '10:00', end: '17:00' })
    expect(normalized.sat).toBeUndefined()
  })

  it('keeps explicit day off and fills missing days from defaults', () => {
    const normalized = normalizeWorkingHours({ mon: null, tue: { start: '11:00', end: '15:00' } })

    expect(normalized.mon).toBeNull()
    expect(normalized.tue).toEqual({ start: '11:00', end: '15:00' })
    expect(normalized.wed).toEqual(DEFAULT_WORKING_HOURS.wed)
  })

  it('recovers defaults when all days are disabled or missing', () => {
    expect(normalizeWorkingHours({ mon: null, tue: null })).toEqual(DEFAULT_WORKING_HOURS)
  })

  it('builds initials from one or two words', () => {
    expect(getInitials('Anna Smith')).toBe('AS')
    expect(getInitials('Anna')).toBe('A')
    expect(getInitials('')).toBe('?')
  })

  it('creates initial profile form from user data', () => {
    const form = getInitialProfileForm(makeUser())

    expect(form).toMatchObject({
      fullName: 'Anna Smith',
      displayName: 'Anna',
      email: 'anna@example.com',
      phone: '+1000',
      timezone: 'Europe/London (GMT+1)',
      bio: 'Tutor',
    })
    expect(form.workingHours.mon).toEqual({ start: '10:00', end: '16:00' })
  })
})
