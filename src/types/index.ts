// Core domain types for Slottr.
// Single source of truth — imported by data, components, pages.

/** Supported UI languages. Extend if adding more. */
export type Lang = 'en' | 'ru'

/** Theme variants. */
export type Theme = 'dark' | 'light'

/** A value that has translations for every supported language. */
export type Localized<T = string> = Record<Lang, T>

/** Visual tone for pills/badges. Mirrors `.pill-*` CSS classes. */
export type PillTone = 'muted' | 'accent' | 'success' | 'danger'

/* ============== Services ============== */

/** A bookable service offered by the business. */
export interface Service {
  /** json-server generates this as a string (UUID-like) or numeric — both are fine. */
  id: string
  /** Owner (specialist) user id. Server-assigned from JWT — clients never send this. */
  providerId: number
  /** Category, e.g. "Strategy" / "Стратегия". Used for filtering. */
  tag: Localized
  /** Visual emphasis on the card. */
  tone: PillTone
  /** Duration in minutes. */
  duration: number
  /** Price in USD. */
  price: number
  name: Localized
  description: Localized
}

/**
 * Payload sent to POST /services or PATCH /services/:id.
 * Excludes server-managed fields (id, providerId).
 */
export type ServicePayload = Omit<Service, 'id' | 'providerId'>

/* ============== Bookings ============== */

export type BookingStatus = 'confirmed' | 'pending' | 'cancelled'

/** A scheduled appointment in the system. */
export interface Booking {
  id: string
  /** Specialist (service owner) user id — derived server-side from the service. */
  providerId: number
  /** Display name snapshot of the provider, set by the server at booking time.
   *  Used by the customer-side UI to show "with Anna" without an extra user lookup. */
  providerName?: string
  /** Customer (booker) user id — derived server-side from the JWT. */
  customerId: number
  /** "YYYY-MM-DD" in local time. */
  dateISO: string
  /** "HH:MM" start. */
  time: string
  /** "HH:MM" end. Optional only for legacy records — newer bookings always have it. */
  endTime?: string
  /** Duration in minutes (denormalized from service for snapshot integrity). */
  durationMin: number
  /** Reference to the service id, may be missing on legacy records. */
  serviceId?: string
  /** Service name snapshot in the language used at booking time. */
  service: string
  /** Price snapshot at booking time. */
  total: number
  status: BookingStatus
  /** Display name of the customer. */
  withName: string
  /** 2-letter initials for avatar. */
  initials: string
  customerEmail: string
  customerPhone?: string | null
  notes?: string | null
  /** ISO timestamp set by the server on create. */
  createdAt?: string
}

/**
 * Payload for POST /bookings.
 * Excludes server-managed fields: id, createdAt, providerId, customerId.
 */
export type BookingPayload = Omit<Booking, 'id' | 'createdAt' | 'providerId' | 'customerId'>

/** Payload for PATCH /bookings/:id — any subset, owner fields locked by server. */
export type BookingPatch = Partial<Omit<Booking, 'id' | 'createdAt' | 'providerId' | 'customerId'>>

/* ============== Notifications ============== */

export type NotificationKind = 'check' | 'calendar' | 'user' | 'dollar' | 'star' | 'close' | 'clock'

/**
 * Notification stored on the server (per-user).
 * Title/text are formatted on the client from `kind` + `params`, so the same
 * record renders correctly in any language.
 */
export interface AppNotification {
  id: number
  userId: number
  kind: NotificationKind
  tone?: PillTone
  /** ISO timestamp when the notification was created. */
  createdAt: string
  unread?: boolean
  /** Free-form interpolation params for the title/text templates. */
  params?: {
    service?: string
    withName?: string
    dateISO?: string
    time?: string
  }
}

/* ============== UI helpers ============== */

/** A field that can be either a plain string OR a localized object — used by `loc()`. */
export type MaybeLocalized = string | Localized | null | undefined

/* ============== Auth ============== */

/** A single working window inside a day. */
export interface DayHours {
  start: string // "HH:MM"
  end: string // "HH:MM"
}

/** Day-of-week keys for WorkingHours. Monday-first to match ISO 8601. */
export type DayKey = 'mon' | 'tue' | 'wed' | 'thu' | 'fri' | 'sat' | 'sun'

export const DAY_KEYS: readonly DayKey[] = ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun']

/**
 * Per-day working hours. Missing/null/undefined for a day = day off.
 * Default for new users is mon..fri 09:00-18:00.
 */
export type WorkingHours = Partial<Record<DayKey, DayHours | null>>

/** User as stored in JSON Server (password never returned by API). */
export interface User {
  id: number
  email: string
  name: string
  /** Display name, defaults to first word of `name` if not set. */
  displayName?: string
  phone?: string
  timezone?: string
  bio?: string
  workingHours?: WorkingHours
}

/** Availability response from GET /availability/:providerId. */
export interface AvailabilitySlot {
  time: string // "HH:MM"
  available: boolean
}

export interface AvailabilityResponse {
  /** All slots between workingHours.start and end-duration, with availability flag. */
  slots: AvailabilitySlot[]
  /** The provider's working window for the requested day, or null if day off. */
  workingHours: DayHours | null
}

/** Response shape from POST /login, /register, and /refresh. */
export interface AuthResponse {
  accessToken: string
  refreshToken: string
  user: User
}

/** Payload for POST /login. */
export interface LoginPayload {
  email: string
  password: string
}

/** Payload for POST /register. */
export interface RegisterPayload {
  email: string
  password: string
  name: string
}
