import { apiFetch } from './http'
import type { AvailabilityResponse } from '../types'

/**
 * GET /availability/:providerId?date=YYYY-MM-DD&duration=N
 * Returns the provider's working window for that day + which slots are free.
 */
export function getAvailability(
  providerId: number,
  dateISO: string,
  duration: number,
): Promise<AvailabilityResponse> {
  const params = new URLSearchParams({ date: dateISO, duration: String(duration) })
  return apiFetch<AvailabilityResponse>(`/availability/${providerId}?${params.toString()}`)
}
