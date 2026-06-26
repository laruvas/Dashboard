// Shared HTTP layer for the REST API.
//
// Token model (matches backend):
//   - Access token  (JWT, 15 min) — sent as Authorization: Bearer on every call.
//   - Refresh token (opaque, 30 days) — used only against POST /refresh.
//
// On a 401, we try to silently mint a new access token via /refresh and replay
// the original request. If /refresh itself fails, we dispatch `auth-expired`
// and AuthContext logs the user out.
//
// Single-flight: parallel 401s share one in-flight /refresh promise so we don't
// stampede the server with a dozen rotations at once.

// In dev: defaults to local Express on :3001.
// In prod: set VITE_API_URL on Vercel (e.g. https://slottr-api.onrender.com).
export const BASE_URL =
  (import.meta.env.VITE_API_URL as string | undefined) || 'http://localhost:3001'

export const AUTH_EXPIRED_EVENT = 'slottr:auth-expired'

let currentAccess: string | null = null
let currentRefresh: string | null = null

/**
 * Called by AuthContext whenever the session changes (login / refresh / logout).
 * Pass both tokens together so http.ts always has a consistent pair.
 */
export function setAuthTokens(access: string | null, refresh: string | null): void {
  currentAccess = access
  currentRefresh = refresh
}

/** Back-compat shim — old callers passed only the access token. */
export function setAuthToken(access: string | null): void {
  currentAccess = access
  if (access === null) currentRefresh = null
}

export function getAuthToken(): string | null {
  return currentAccess
}
export function getRefreshToken(): string | null {
  return currentRefresh
}

export class HttpError extends Error {
  constructor(
    message: string,
    public readonly status: number,
  ) {
    super(message)
    this.name = 'HttpError'
  }
}

interface ApiFetchOptions extends Omit<RequestInit, 'body' | 'headers'> {
  json?: unknown
  headers?: Record<string, string>
  /** Skip the global 401 → /refresh → retry dance (used by /login, /register, /refresh itself). */
  skipAuthRedirect?: boolean
}

async function readErrorMessage(res: Response): Promise<string> {
  try {
    const body = await res.text()
    if (!body) return `Request failed (${res.status})`
    const stripped = body.replace(/^"|"$/g, '')
    try {
      const parsed = JSON.parse(body) as { message?: string; error?: string }
      return parsed.message || parsed.error || stripped || `Request failed (${res.status})`
    } catch {
      return stripped || `Request failed (${res.status})`
    }
  } catch {
    return `Request failed (${res.status})`
  }
}

/** Shape of POST /refresh response (kept local to avoid a circular import with types). */
interface RefreshResponse {
  accessToken: string
  refreshToken: string
  // `user` is also returned but ignored here — AuthContext owns user state.
}

/**
 * Callback invoked when /refresh succeeds, so AuthContext can mirror the new
 * tokens into its own state and localStorage. Set once during AuthProvider init.
 */
let onTokensRefreshed: ((access: string, refresh: string) => void) | null = null
export function setOnTokensRefreshed(cb: ((access: string, refresh: string) => void) | null): void {
  onTokensRefreshed = cb
}

/** Single-flight slot for an in-progress /refresh call. */
let refreshInFlight: Promise<string | null> | null = null

/**
 * Try to obtain a fresh access token using the stored refresh token.
 * Returns the new access token, or null if refresh is impossible (no refresh
 * token, or server rejected it). Parallel callers share the same promise.
 */
function attemptRefresh(): Promise<string | null> {
  if (refreshInFlight) return refreshInFlight
  const refresh = currentRefresh
  if (!refresh) return Promise.resolve(null)

  refreshInFlight = (async () => {
    try {
      const res = await fetch(`${BASE_URL}/refresh`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ refreshToken: refresh }),
      })
      if (!res.ok) return null
      const data = (await res.json()) as RefreshResponse
      currentAccess = data.accessToken
      currentRefresh = data.refreshToken
      onTokensRefreshed?.(data.accessToken, data.refreshToken)
      return data.accessToken
    } catch {
      return null
    } finally {
      refreshInFlight = null
    }
  })()
  return refreshInFlight
}

/** Build headers/body once — reused by initial call and retry-after-refresh. */
function buildInit(
  json: unknown,
  extraHeaders: Record<string, string> | undefined,
  rest: Omit<RequestInit, 'body' | 'headers'>,
): RequestInit {
  const headers: Record<string, string> = { ...(extraHeaders || {}) }
  let body: BodyInit | undefined
  if (json !== undefined) {
    headers['Content-Type'] = 'application/json'
    body = JSON.stringify(json)
  }
  if (currentAccess) headers['Authorization'] = `Bearer ${currentAccess}`
  return { ...rest, headers, body }
}

export async function apiFetch<T>(path: string, options: ApiFetchOptions = {}): Promise<T> {
  const { json, headers: extraHeaders, skipAuthRedirect, ...rest } = options

  let res = await fetch(`${BASE_URL}${path}`, buildInit(json, extraHeaders, rest))

  // 401 + we have a refresh token → try to silently rotate and retry once.
  if (res.status === 401 && !skipAuthRedirect && currentRefresh) {
    const newAccess = await attemptRefresh()
    if (newAccess) {
      // Replay with the new access token. buildInit picks up currentAccess.
      res = await fetch(`${BASE_URL}${path}`, buildInit(json, extraHeaders, rest))
    }
  }

  // Still 401 after refresh attempt (or no refresh available) → give up.
  if (res.status === 401 && !skipAuthRedirect) {
    const hadToken = currentAccess !== null || currentRefresh !== null
    currentAccess = null
    currentRefresh = null
    if (typeof window !== 'undefined') {
      window.dispatchEvent(new CustomEvent(AUTH_EXPIRED_EVENT, { detail: { hadToken } }))
    }
  }

  if (!res.ok) throw new HttpError(await readErrorMessage(res), res.status)
  if (res.status === 204) return undefined as T
  return res.json() as Promise<T>
}
