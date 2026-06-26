// Generates an .ics (iCalendar 2.0) file for a booking and triggers download.
// Spec: RFC 5545. No external deps.

import type { Booking } from '../types'

function pad(n: number | string): string {
  return String(n).padStart(2, '0')
}

// "2026-06-13" + "11:30" -> "20260613T113000"
function toLocalStamp(dateISO: string, time: string): string {
  const [Y, M, D] = dateISO.split('-')
  const [h, m] = time.split(':')
  return `${Y}${M}${D}T${pad(h)}${pad(m)}00`
}

// "20260610T215543Z" (UTC, for DTSTAMP)
function nowUtcStamp(): string {
  const d = new Date()
  return (
    `${d.getUTCFullYear()}${pad(d.getUTCMonth() + 1)}${pad(d.getUTCDate())}T` +
    `${pad(d.getUTCHours())}${pad(d.getUTCMinutes())}${pad(d.getUTCSeconds())}Z`
  )
}

// Escape per RFC 5545 §3.3.11
function esc(text: string | null | undefined = ''): string {
  return String(text)
    .replace(/\\/g, '\\\\')
    .replace(/\n/g, '\\n')
    .replace(/,/g, '\\,')
    .replace(/;/g, '\\;')
}

// Fold lines longer than 75 octets (per RFC 5545 §3.1) — keep it simple, fold by chars.
function fold(line: string): string {
  if (line.length <= 75) return line
  const chunks: string[] = []
  let i = 0
  while (i < line.length) {
    chunks.push((i === 0 ? '' : ' ') + line.slice(i, i + 74))
    i += 74
  }
  return chunks.join('\r\n')
}

export function buildIcsBlob(booking: Booking): Blob {
  const tzid = Intl.DateTimeFormat().resolvedOptions().timeZone || 'UTC'
  const dtStart = toLocalStamp(booking.dateISO, booking.time)
  const dtEnd = toLocalStamp(booking.dateISO, booking.endTime || booking.time)
  const uid = `${booking.id}@slottr.app`

  const summary = `${booking.service}${booking.withName ? ` — ${booking.withName}` : ''}`
  const descBits: string[] = []
  if (booking.customerEmail) descBits.push(`Customer: ${booking.customerEmail}`)
  if (booking.customerPhone) descBits.push(`Phone: ${booking.customerPhone}`)
  if (booking.notes) descBits.push(`Notes: ${booking.notes}`)
  if (booking.total != null) descBits.push(`Total: $${booking.total}`)
  const description = descBits.join('\n')

  const lines: (string | false)[] = [
    'BEGIN:VCALENDAR',
    'VERSION:2.0',
    'PRODID:-//Slottr//Appointment Scheduler//EN',
    'CALSCALE:GREGORIAN',
    'METHOD:PUBLISH',
    'BEGIN:VEVENT',
    `UID:${uid}`,
    `DTSTAMP:${nowUtcStamp()}`,
    `DTSTART;TZID=${tzid}:${dtStart}`,
    `DTEND;TZID=${tzid}:${dtEnd}`,
    `SUMMARY:${esc(summary)}`,
    description && `DESCRIPTION:${esc(description)}`,
    'LOCATION:Online · Zoom',
    'STATUS:CONFIRMED',
    'END:VEVENT',
    'END:VCALENDAR',
  ]
  const folded = lines.filter((l): l is string => Boolean(l)).map(fold)

  // RFC 5545 requires CRLF line endings
  const ics = folded.join('\r\n') + '\r\n'
  return new Blob([ics], { type: 'text/calendar;charset=utf-8' })
}

export function downloadIcs(booking: Booking, filename: string = 'booking.ics'): void {
  const blob = buildIcsBlob(booking)
  const url = URL.createObjectURL(blob)
  const a = document.createElement('a')
  a.href = url
  a.download = filename
  document.body.appendChild(a)
  a.click()
  document.body.removeChild(a)
  // Revoke after a tick to ensure download started
  setTimeout(() => URL.revokeObjectURL(url), 1000)
}
