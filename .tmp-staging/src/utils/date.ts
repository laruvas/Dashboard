// Date helpers. No external deps — uses native Date with day-precision math.

/** "YYYY-MM-DD" in local time. */
export function toISODate(d: Date): string {
  const yyyy = d.getFullYear()
  const mm = String(d.getMonth() + 1).padStart(2, '0')
  const dd = String(d.getDate()).padStart(2, '0')
  return `${yyyy}-${mm}-${dd}`
}

/** Date at midnight (start of day) — useful for comparison. */
export function startOfDay(d: Date): Date {
  return new Date(d.getFullYear(), d.getMonth(), d.getDate())
}

/** Monday of the week containing the given date. */
export function startOfWeek(d: Date): Date {
  const day = (d.getDay() + 6) % 7 // Mon=0, Sun=6
  const monday = new Date(d.getFullYear(), d.getMonth(), d.getDate() - day)
  return monday
}

/** Sunday (23:59:59.999) of the week containing the given date. */
export function endOfWeek(d: Date): Date {
  const monday = startOfWeek(d)
  const sunday = new Date(monday.getFullYear(), monday.getMonth(), monday.getDate() + 6, 23, 59, 59, 999)
  return sunday
}

/** First day of the month containing the given date. */
export function startOfMonth(d: Date): Date {
  return new Date(d.getFullYear(), d.getMonth(), 1)
}

/** Last day of the month containing the given date (23:59:59.999). */
export function endOfMonth(d: Date): Date {
  return new Date(d.getFullYear(), d.getMonth() + 1, 0, 23, 59, 59, 999)
}

/** Add `days` to the given date (returns a new Date). */
export function addDays(d: Date, days: number): Date {
  return new Date(d.getFullYear(), d.getMonth(), d.getDate() + days)
}

/** True if two dates fall on the same calendar day (local time). */
export function isSameDay(a: Date, b: Date): boolean {
  return a.getFullYear() === b.getFullYear()
      && a.getMonth() === b.getMonth()
      && a.getDate() === b.getDate()
}

/** Check if booking's dateISO is within [start, end] inclusive (day precision). */
export function isWithinRange(dateISO: string, start: Date, end: Date): boolean {
  if (!dateISO) return false
  const startISO = toISODate(start)
  const endISO = toISODate(end)
  return dateISO >= startISO && dateISO <= endISO
}

/** Convert "HH:MM" to minutes since 00:00. */
export function timeToMinutes(time: string): number {
  const [h, m] = time.split(':').map(Number)
  return h * 60 + m
}
