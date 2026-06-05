import { apiFetch } from './http'
import type { Service, ServicePayload } from '../types'

/** GET /services — only services owned by the current user (my catalog). */
export function listServices(): Promise<Service[]> {
  return apiFetch<Service[]>('/services')
}

/** GET /services/:id — current user's service (server enforces ownership). */
export function getService(id: string): Promise<Service> {
  return apiFetch<Service>(`/services/${id}`)
}

/** POST /services. Server forces providerId from JWT — client must not send it. */
export function createService(payload: ServicePayload): Promise<Service> {
  return apiFetch<Service>('/services', { method: 'POST', json: payload })
}

export function patchService(id: string, partial: Partial<ServicePayload>): Promise<Service> {
  return apiFetch<Service>(`/services/${id}`, { method: 'PATCH', json: partial })
}

export function deleteService(id: string): Promise<void> {
  return apiFetch<void>(`/services/${id}`, { method: 'DELETE' })
}
