import { loc } from '../../data/mock'
import type { Booking, Lang, Service } from '../../types'

export function toISODate(d: Date): string {
  const yyyy = d.getFullYear()
  const mm = String(d.getMonth() + 1).padStart(2, '0')
  const dd = String(d.getDate()).padStart(2, '0')
  return `${yyyy}-${mm}-${dd}`
}

export function addMinutesHHMM(time: string, minutesToAdd: number): string {
  const [hStr, mStr] = time.split(':')
  const total = Number(hStr) * 60 + Number(mStr) + minutesToAdd
  const h = String(Math.floor(total / 60) % 24).padStart(2, '0')
  const m = String(total % 60).padStart(2, '0')
  return `${h}:${m}`
}

// "10:00" -> 600 (minutes since 00:00)
export function toMinutes(time: string): number {
  const [h, m] = time.split(':').map(Number)
  return h * 60 + m
}

// "Anna Smith" -> "AS"
export function initialsFrom(name: string): string {
  if (!name) return '?'
  return (
    name
      .trim()
      .split(/\s+/)
      .slice(0, 2)
      .map((w) => w[0]?.toUpperCase() || '')
      .join('') || '?'
  )
}

export function matchesServiceQuery(s: Service, q: string, lang: Lang): boolean {
  if (!q) return true
  const haystack = [
    loc(s.name, lang),
    loc(s.description, lang),
    loc(s.tag, lang),
    s.name?.en,
    s.name?.ru,
    s.description?.en,
    s.description?.ru,
    s.tag?.en,
    s.tag?.ru,
  ]
    .filter(Boolean)
    .join(' ')
    .toLowerCase()
  return haystack.includes(q.toLowerCase())
}

export function getBookingEventDates(bookings: Booking[]): Date[] {
  const dates: Date[] = []
  for (const b of bookings) {
    if (!b.dateISO || b.status === 'cancelled') continue
    const [y, m, d] = b.dateISO.split('-').map(Number)
    if (!y || !m || !d) continue
    dates.push(new Date(y, m - 1, d))
  }
  return dates
}

export function isDateInPast(date: Date): boolean {
  const today = new Date()
  const todayMid = new Date(today.getFullYear(), today.getMonth(), today.getDate())
  const selectedMid = new Date(date.getFullYear(), date.getMonth(), date.getDate())
  return selectedMid < todayMid
}
