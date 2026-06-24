import type { Booking, Lang } from '../../types'
import type { AnnotatedBooking, BookingGroups, StatusTab } from './bookingsTypes'

export function formatDateShort(iso: string | undefined, lang: Lang): string {
  if (!iso) return '—'
  const [y, m, d] = iso.split('-').map(Number)
  const date = new Date(y, m - 1, d)
  return date.toLocaleDateString(lang === 'ru' ? 'ru-RU' : 'en-US', { month: 'short', day: 'numeric' })
}

export function toISODate(d: Date): string {
  const yyyy = d.getFullYear()
  const mm = String(d.getMonth() + 1).padStart(2, '0')
  const dd = String(d.getDate()).padStart(2, '0')
  return `${yyyy}-${mm}-${dd}`
}

export function sortBookings(bookings: Booking[]): Booking[] {
  return [...bookings].sort((a, b) => {
    const byDate = (a.dateISO || '').localeCompare(b.dateISO || '')
    if (byDate !== 0) return byDate
    return (a.time || '').localeCompare(b.time || '')
  })
}

export function annotateBookings(bookings: Booking[]): AnnotatedBooking[] {
  return bookings.map(b => ({ b }))
}

export function groupBookingsByStatus(annotated: AnnotatedBooking[], todayISO = toISODate(new Date())): BookingGroups {
  const upcoming: AnnotatedBooking[] = []
  const past: AnnotatedBooking[] = []
  const cancelled: AnnotatedBooking[] = []

  for (const x of annotated) {
    if (x.b.status === 'cancelled') cancelled.push(x)
    else if ((x.b.dateISO || '') >= todayISO) upcoming.push(x)
    else past.push(x)
  }

  return { upcoming, past, cancelled }
}

export function filterBookings(
  groups: BookingGroups,
  status: StatusTab,
  query: string,
): AnnotatedBooking[] {
  const list = groups[status] || []
  const q = query.trim().toLowerCase()
  if (!q) return list

  return list.filter(({ b }) =>
    (b.withName || '').toLowerCase().includes(q) ||
    (b.service || '').toLowerCase().includes(q) ||
    (b.customerEmail || '').toLowerCase().includes(q) ||
    (b.dateISO || '').includes(q),
  )
}

export function addMinutesHHMM(time: string, minutesToAdd: number): string {
  const [hStr, mStr] = time.split(':')
  const total = Number(hStr) * 60 + Number(mStr) + minutesToAdd
  return `${String(Math.floor(total / 60) % 24).padStart(2, '0')}:${String(total % 60).padStart(2, '0')}`
}
