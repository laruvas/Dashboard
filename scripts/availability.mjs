// Pure helpers for availability / slot calculation.
// Kept side-effect free so unit tests can exercise edge cases without a DB.
//
// DAY_KEYS ordering matches `getDay()`: JS getDay returns 0=Sun..6=Sat,
// we map to a Mon-first index.

export const DAY_KEYS = ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun']

export const DEFAULT_WORKING_HOURS = {
  mon: { start: '09:00', end: '18:00' },
  tue: { start: '09:00', end: '18:00' },
  wed: { start: '09:00', end: '18:00' },
  thu: { start: '09:00', end: '18:00' },
  fri: { start: '09:00', end: '18:00' },
}

/** Convert 'HH:MM' to minutes since midnight. Returns NaN on garbage input. */
export function hhmmToMin(s) {
  const [h, m] = String(s).split(':').map(Number)
  return h * 60 + m
}

/** Convert minutes since midnight back to 'HH:MM'. Wraps modulo 24. */
export function minToHHMM(min) {
  const safe = Number(min) || 0
  const h = Math.floor(safe / 60) % 24
  const m = safe % 60
  return `${String(h).padStart(2, '0')}:${String(m).padStart(2, '0')}`
}

/**
 * Coerce a possibly-malformed `workingHours` payload to a sane shape.
 * Accepts:
 *   - missing / null / non-object → defaults (Mon-Fri 9-18)
 *   - legacy flat `{ start, end }` → expanded to Mon-Fri
 *   - per-day `{ mon: {...}, tue: {...}, ... }` → returned as-is (after sanity check)
 */
export function normalizeWorkingHours(wh) {
  if (!wh || typeof wh !== 'object') return DEFAULT_WORKING_HOURS
  if (typeof wh.start === 'string' && typeof wh.end === 'string') {
    return DAY_KEYS.slice(0, 5).reduce((acc, k) => {
      acc[k] = { start: wh.start, end: wh.end }
      return acc
    }, {})
  }
  const hasAnyDay = DAY_KEYS.some(k => wh[k])
  if (!hasAnyDay) return DEFAULT_WORKING_HOURS
  return wh
}

/** 'YYYY-MM-DD' → 'mon'..'sun'. Uses local time (matches server behaviour). */
export function dowKeyFromISO(iso) {
  const [y, m, d] = iso.split('-').map(Number)
  const jsDow = new Date(y, m - 1, d).getDay()
  return DAY_KEYS[jsDow === 0 ? 6 : jsDow - 1]
}

/** Format a Date as local YYYY-MM-DD. Stable enough for testing. */
export function formatYMD(date) {
  const d = date instanceof Date ? date : new Date(date)
  return `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-${String(d.getDate()).padStart(2, '0')}`
}

/**
 * Build the list of slots for a given day.
 *
 * @param {object} params
 * @param {{start:string,end:string}|null} params.window  Working hours for that day, or null if the provider is closed.
 * @param {Array<[number,number]>}      params.blocking Pre-existing bookings as [startMin, endMin] pairs.
 * @param {Date}                        params.now      "Current" time — injectable for tests.
 * @param {string}                      params.dateISO  'YYYY-MM-DD' for the day being queried.
 * @param {number}                      params.duration Service length in minutes.
 * @param {number}                      [params.step=60] Granularity of slot start times.
 * @param {number}                      [params.minNoticeMin=60] Min minutes from `now` for a same-day slot.
 * @returns {Array<{time:string, available:boolean}>}
 */
export function calculateSlots({
  window,
  blocking,
  now,
  dateISO,
  duration,
  step = 60,
  minNoticeMin = 60,
}) {
  if (!window) return []
  if (!Number.isFinite(duration) || duration <= 0) return []

  const startMin = hhmmToMin(window.start)
  const endMin = hhmmToMin(window.end)
  const todayISO = formatYMD(now)
  const isToday = dateISO === todayISO
  const nowMin = isToday ? now.getHours() * 60 + now.getMinutes() : -Infinity
  const cutoffMin = isToday ? nowMin + minNoticeMin : -Infinity

  const slots = []
  for (let s = startMin; s + duration <= endMin; s += step) {
    const e = s + duration
    let available = true
    if (s < cutoffMin) {
      available = false
    } else {
      for (const [bs, be] of blocking) {
        // Half-open intervals [s,e) and [bs,be) overlap iff s < be && bs < e.
        if (s < be && bs < e) { available = false; break }
      }
    }
    slots.push({ time: minToHHMM(s), available })
  }
  return slots
}
