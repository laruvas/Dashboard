import { DAY_KEYS, type WorkingHours } from '../../types'
import type { User } from '../../types'
import type { ProfileFormValues } from './profileTypes'

export const DEFAULT_WORKING_HOURS: WorkingHours = {
  mon: { start: '09:00', end: '18:00' },
  tue: { start: '09:00', end: '18:00' },
  wed: { start: '09:00', end: '18:00' },
  thu: { start: '09:00', end: '18:00' },
  fri: { start: '09:00', end: '18:00' },
}

/**
 * Backwards-compat: old User.workingHours was {start, end} (one window for all days).
 * Spread into Mon-Fri so existing users don't lose data on first edit.
 */
export function normalizeWorkingHours(
  wh: WorkingHours | { start?: string; end?: string } | undefined,
): WorkingHours {
  if (!wh) return DEFAULT_WORKING_HOURS

  const legacy = wh as { start?: string; end?: string }
  if (typeof legacy.start === 'string' && typeof legacy.end === 'string') {
    const w = { start: legacy.start, end: legacy.end }
    return { mon: w, tue: w, wed: w, thu: w, fri: w }
  }

  const newShape = wh as WorkingHours
  // Recovery: if every day is null or missing (e.g. user accidentally disabled
  // all days, or a buggy save wiped the object), restore defaults so they don't
  // end up with no availability at all.
  const hasAnyDay = DAY_KEYS.some((k) => newShape[k])
  if (!hasAnyDay) return DEFAULT_WORKING_HOURS

  // Fill in missing (undefined) days from DEFAULT_WORKING_HOURS so partially-saved
  // profiles show all days the server actually treats as working. Explicit `null`
  // stays — that's the user's intent ("day off").
  const filled: WorkingHours = { ...newShape }
  for (const k of DAY_KEYS) {
    if (!(k in filled)) filled[k] = DEFAULT_WORKING_HOURS[k] ?? null
  }
  return filled
}

export function getInitials(name: string): string {
  return (
    name
      .trim()
      .split(/\s+/)
      .slice(0, 2)
      .map((w) => w[0]?.toUpperCase() || '')
      .join('') || '?'
  )
}

export function getInitialProfileForm(user: User | null): ProfileFormValues {
  return {
    fullName: user?.name || '',
    displayName: user?.displayName || user?.name?.split(' ')[0] || '',
    email: user?.email || '',
    phone: user?.phone || '',
    timezone: user?.timezone || 'Europe/Moscow (GMT+3)',
    bio: user?.bio || '',
    workingHours: normalizeWorkingHours(user?.workingHours),
  }
}
