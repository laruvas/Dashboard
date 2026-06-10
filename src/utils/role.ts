// Helpers for figuring out the current user's role on a booking.
// A user is always exactly one of: provider, customer (can't be both — server
// rejects self-bookings).

import type { Booking } from '../types'

export type BookingRole = 'provider' | 'customer'

/**
 * Returns 'provider' if the user owns the service, 'customer' if they made the booking,
 * or null if neither (shouldn't happen — the server filters /bookings already).
 */
export function bookingRole(b: Booking, userId: number | undefined): BookingRole | null {
  if (userId == null) return null
  if (Number(b.providerId) === userId) return 'provider'
  if (Number(b.customerId) === userId) return 'customer'
  return null
}

/**
 * Display name of "the other party" in the booking, depending on the current user's role:
 *  - provider sees the customer's name (b.withName, captured in the booking form)
 *  - customer sees the provider's name (b.providerName, snapshot at booking time)
 */
export function counterpartyName(b: Booking, role: BookingRole | null): string {
  if (role === 'customer') return b.providerName || '—'
  // provider, or unknown — fall back to the customer-side name
  return b.withName || '—'
}
