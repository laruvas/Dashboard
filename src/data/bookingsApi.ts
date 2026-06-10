import { apiFetch } from './http'
import type { Booking, BookingPayload, BookingPatch } from '../types'

/** Server filters to bookings where the current user is provider OR customer. */
export function listBookings(): Promise<Booking[]> {
  return apiFetch<Booking[]>('/bookings')
}

export function getBooking(id: string): Promise<Booking> {
  return apiFetch<Booking>(`/bookings/${id}`)
}

/**
 * POST /bookings. The server forces customerId from the JWT and derives providerId
 * from the referenced service, so the client must NOT send either field.
 */
export function createBooking(payload: BookingPayload): Promise<Booking> {
  return apiFetch<Booking>('/bookings', {
    method: 'POST',
    json: { ...payload, createdAt: new Date().toISOString() },
  })
}

export function patchBooking(id: string, partial: BookingPatch): Promise<Booking> {
  return apiFetch<Booking>(`/bookings/${id}`, { method: 'PATCH', json: partial })
}

export function deleteBooking(id: string): Promise<void> {
  return apiFetch<void>(`/bookings/${id}`, { method: 'DELETE' })
}
