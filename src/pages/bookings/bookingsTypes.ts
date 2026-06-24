import type { Booking } from '../../types'

export type StatusTab = 'upcoming' | 'past' | 'cancelled'

export interface AnnotatedBooking {
  b: Booking
}

export interface BookingGroups {
  upcoming: AnnotatedBooking[]
  past: AnnotatedBooking[]
  cancelled: AnnotatedBooking[]
}
