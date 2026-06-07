// Static mock data that doesn't live on the server.
// `services`, `bookings` and `notifications` all migrated to JSON Server.
// Only the `loc()` helper for localized fields stays here.

import type { Lang, Localized, MaybeLocalized } from '../types'

/**
 * Extract a localized value:
 * - string  → returned as-is (back-compat for legacy data)
 * - Localized → returned in the requested lang, falling back to `en`
 * - null/undefined → empty string
 */
export function loc(field: MaybeLocalized, lang: Lang = 'en'): string {
  if (field == null) return ''
  if (typeof field === 'string') return field
  const obj = field as Localized
  return obj[lang] ?? obj.en ?? ''
}
