// Auth API — login & register against json-server-auth, plus user updates.
// Pure fetch wrappers, no state. State lives in AuthContext.

import { apiFetch, HttpError } from './http'
import type { AuthResponse, LoginPayload, RegisterPayload, User } from '../types'

/** Public alias so existing callers keep the same import name. */
export { HttpError as AuthError }

export function login(payload: LoginPayload): Promise<AuthResponse> {
  // skipAuthRedirect: a 401 from /login is "wrong password", not an expired session.
  return apiFetch<AuthResponse>('/login', { method: 'POST', json: payload, skipAuthRedirect: true })
}

export function register(payload: RegisterPayload): Promise<AuthResponse> {
  return apiFetch<AuthResponse>('/register', { method: 'POST', json: payload, skipAuthRedirect: true })
}

/** Update user fields. Server enforces ownership via the Bearer token. */
export function updateUser(id: number, patch: Partial<Omit<User, 'id'>>): Promise<User> {
  return apiFetch<User>(`/users/${id}`, { method: 'PATCH', json: patch })
}

/** Fetch full user record by id (with role and other server-managed fields). */
export function getUser(id: number): Promise<User> {
  return apiFetch<User>(`/users/${id}`)
}

/** Server-side logout: invalidates the refresh token so it can't be reused. */
export function serverLogout(refreshToken: string | null): Promise<{ ok: true }> {
  // Idempotent on the server: returns 200 even if the token doesn't exist.
  // skipAuthRedirect — we don't want a 401 here to trigger /refresh recursion.
  return apiFetch<{ ok: true }>('/logout', {
    method: 'POST',
    json: { refreshToken },
    skipAuthRedirect: true,
  })
}
