import { apiFetch } from './http'
import type { AppNotification } from '../types'

/** GET /notifications — current user's feed, newest first. */
export function listNotifications(): Promise<AppNotification[]> {
  return apiFetch<AppNotification[]>('/notifications')
}

/** Mark a single notification as read/unread. */
export function patchNotification(
  id: number,
  patch: { unread?: boolean },
): Promise<AppNotification> {
  return apiFetch<AppNotification>(`/notifications/${id}`, { method: 'PATCH', json: patch })
}

/** Server-side bulk mark-all-as-read. */
export function markAllRead(): Promise<{ ok: true }> {
  return apiFetch<{ ok: true }>('/notifications/mark-all-read', { method: 'POST' })
}

export function deleteNotification(id: number): Promise<void> {
  return apiFetch<void>(`/notifications/${id}`, { method: 'DELETE' })
}
