import type { Booking, Lang } from '../../types'

export function formatBookingDate(iso: string | undefined, lang: Lang): string {
  if (!iso) return ''
  const [y, m, d] = iso.split('-').map(Number)
  const date = new Date(y, m - 1, d)
  return date.toLocaleDateString(lang === 'ru' ? 'ru-RU' : 'en-US', {
    weekday: 'short',
    month: 'long',
    day: 'numeric',
    year: 'numeric',
  })
}

export function getBookingRef(id: Booking['id']): string {
  return `SLT-${String(id).padStart(4, '0')}`
}

export function getBookingTimeRange(booking: Booking): string {
  return booking.endTime ? `${booking.time} – ${booking.endTime}` : booking.time
}

export function getStatusTone(status: Booking['status']): 'success' | 'danger' | 'accent' {
  if (status === 'cancelled') return 'danger'
  if (status === 'confirmed') return 'success'
  return 'accent'
}
