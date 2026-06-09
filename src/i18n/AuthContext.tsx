// Auth state container. Persists to localStorage so refreshes keep the session.
// API:
//   const { user, token, login, register, logout, isAuthenticated } = useAuth()
//
// Token model:
// - accessToken  (JWT, 15 min) — sent on every API call
// - refreshToken (opaque, 30 days) — used to silently mint new access tokens
//
// http.ts handles the 401 → /refresh → retry dance transparently. When it
// rotates tokens it calls back via setOnTokensRefreshed so we persist the new
// pair into localStorage. The user never sees a re-login screen as long as
// the refresh token is alive.

import { createContext, useCallback, useContext, useEffect, useMemo, useRef, useState, type ReactNode } from 'react'
import {
  login as apiLogin,
  register as apiRegister,
  updateUser as apiUpdateUser,
  getUser as fetchMe,
  serverLogout,
} from '../data/authApi'
import { setAuthTokens, setOnTokensRefreshed, AUTH_EXPIRED_EVENT } from '../data/http'
import { useToast } from '../components/Toast'
import { useT } from './SettingsContext'
import type { AuthResponse, LoginPayload, RegisterPayload, User } from '../types'

const STORAGE_KEY = 'slottr.auth'

interface AuthState {
  user: User
  accessToken: string
  refreshToken: string
}

function readStored(): AuthState | null {
  if (typeof window === 'undefined') return null
  try {
    const raw = localStorage.getItem(STORAGE_KEY)
    if (!raw) return null
    const parsed = JSON.parse(raw) as Partial<AuthState> & { token?: string }
    // Back-compat: older sessions stored {user, token} without a refreshToken.
    // Treat them as missing — they'll have to log in again. Acceptable one-time cost.
    if (!parsed?.user?.id || !parsed?.accessToken || !parsed?.refreshToken) return null
    return parsed as AuthState
  } catch {
    return null
  }
}

interface AuthContextValue {
  user: User | null
  token: string | null
  isAuthenticated: boolean
  login: (payload: LoginPayload) => Promise<void>
  register: (payload: RegisterPayload) => Promise<void>
  logout: () => void
  updateProfile: (patch: Partial<Omit<User, 'id'>>) => Promise<void>
}

const AuthContext = createContext<AuthContextValue | null>(null)

export function AuthProvider({ children }: { children: ReactNode }) {
  const toast = useToast()
  const t = useT()
  const [state, setState] = useState<AuthState | null>(() => {
    const stored = readStored()
    // Prime http BEFORE first render so the initial fetch already has tokens.
    setAuthTokens(stored?.accessToken ?? null, stored?.refreshToken ?? null)
    return stored
  })

  // Keep a ref to current state so the http callback (registered once) always
  // sees fresh values without re-subscribing on every render.
  const stateRef = useRef(state)
  stateRef.current = state

  // Mirror state -> localStorage + http module.
  useEffect(() => {
    if (state) localStorage.setItem(STORAGE_KEY, JSON.stringify(state))
    else localStorage.removeItem(STORAGE_KEY)
    setAuthTokens(state?.accessToken ?? null, state?.refreshToken ?? null)
  }, [state])

  // When http.ts silently rotates tokens (post-401 → /refresh), mirror the new
  // pair into React state so the next render + localStorage stay in sync.
  useEffect(() => {
    setOnTokensRefreshed((access, refresh) => {
      const curr = stateRef.current
      if (!curr) return
      setState({ ...curr, accessToken: access, refreshToken: refresh })
    })
    return () => setOnTokensRefreshed(null)
  }, [])

  // Global 401 handler — fired only when /refresh ALSO failed (real logout).
  useEffect(() => {
    const onExpired = (e: Event) => {
      const hadToken = (e as CustomEvent<{ hadToken?: boolean }>).detail?.hadToken
      setState(null)
      if (hadToken) toast.error(t('auth.sessionExpired'))
    }
    window.addEventListener(AUTH_EXPIRED_EVENT, onExpired)
    return () => window.removeEventListener(AUTH_EXPIRED_EVENT, onExpired)
  }, [toast, t])

  // Session probe on mount: confirm the cached user still exists server-side.
  useEffect(() => {
    const stored = readStored()
    if (!stored) return
    fetchMe(stored.user.id)
      .then((fresh) => {
        setState((prev) => prev ? { ...prev, user: fresh } : prev)
      })
      .catch(() => {
        // 401 → http.ts dispatched AUTH_EXPIRED_EVENT already.
        // Other errors → keep cached state (offline-ish behaviour).
      })
  // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [])

  /** Hydrate user + tokens from a login/register response. */
  const hydrateAndSet = async (resp: AuthResponse) => {
    setAuthTokens(resp.accessToken, resp.refreshToken)
    let fullUser = resp.user
    try {
      fullUser = await fetchMe(resp.user.id)
    } catch {
      // Fallback to partial; server still enforces auth correctly.
    }
    setState({ user: fullUser, accessToken: resp.accessToken, refreshToken: resp.refreshToken })
  }

  const login = useCallback(async (payload: LoginPayload) => {
    await hydrateAndSet(await apiLogin(payload))
  }, [])

  const register = useCallback(async (payload: RegisterPayload) => {
    await hydrateAndSet(await apiRegister(payload))
  }, [])

  const logout = useCallback(() => {
    // Invalidate refresh on the server (best-effort, fire-and-forget).
    const rt = stateRef.current?.refreshToken
    if (rt) serverLogout(rt).catch(() => { /* ignore — local state still cleared */ })
    setState(null)
  }, [])

  const updateProfile = useCallback(async (patch: Partial<Omit<User, 'id'>>) => {
    if (!state) throw new Error('Not authenticated')
    const updated = await apiUpdateUser(state.user.id, patch)
    setState({ ...state, user: updated })
  }, [state])

  const value = useMemo<AuthContextValue>(() => ({
    user: state?.user ?? null,
    token: state?.accessToken ?? null,
    isAuthenticated: !!state,
    login,
    register,
    logout,
    updateProfile,
  }), [state, login, register, logout, updateProfile])

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>
}

export function useAuth(): AuthContextValue {
  const ctx = useContext(AuthContext)
  if (!ctx) throw new Error('useAuth must be used inside <AuthProvider>')
  return ctx
}
