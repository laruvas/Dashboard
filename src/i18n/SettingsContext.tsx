import {
  createContext,
  useCallback,
  useContext,
  useEffect,
  useMemo,
  useState,
  type ReactNode,
} from 'react'
import { translations, type TKey } from './translations'
import type { Lang, Theme } from '../types'

const THEME_KEY = 'slottr.theme'
const LANG_KEY = 'slottr.lang'

interface SettingsContextValue {
  theme: Theme
  setTheme: (t: Theme) => void
  toggleTheme: () => void
  lang: Lang
  setLang: (l: Lang) => void
  toggleLang: () => void
  /** Translate a typed key with optional `{name}` interpolation. */
  t: (key: TKey, params?: Record<string, string | number>) => string
}

const SettingsContext = createContext<SettingsContextValue | null>(null)

function getInitialTheme(): Theme {
  if (typeof window === 'undefined') return 'dark'
  const saved = localStorage.getItem(THEME_KEY)
  if (saved === 'light' || saved === 'dark') return saved
  return window.matchMedia?.('(prefers-color-scheme: light)').matches ? 'light' : 'dark'
}

function getInitialLang(): Lang {
  if (typeof window === 'undefined') return 'en'
  const saved = localStorage.getItem(LANG_KEY)
  if (saved === 'en' || saved === 'ru') return saved
  const browser = (navigator.language || 'en').toLowerCase()
  return browser.startsWith('ru') ? 'ru' : 'en'
}

// Простая интерполяция {n} -> value
function interpolate(str: string, params?: Record<string, string | number>): string {
  if (!params) return str
  return str.replace(/\{(\w+)\}/g, (_, k: string) => (k in params ? String(params[k]) : `{${k}}`))
}

export function SettingsProvider({ children }: { children: ReactNode }) {
  const [theme, setThemeState] = useState<Theme>(getInitialTheme)
  const [lang, setLangState] = useState<Lang>(getInitialLang)

  useEffect(() => {
    document.documentElement.setAttribute('data-theme', theme)
    localStorage.setItem(THEME_KEY, theme)
  }, [theme])

  useEffect(() => {
    document.documentElement.setAttribute('lang', lang)
    localStorage.setItem(LANG_KEY, lang)
  }, [lang])

  const setTheme = useCallback((next: Theme) => setThemeState(next), [])
  const toggleTheme = useCallback(() => setThemeState((t) => (t === 'dark' ? 'light' : 'dark')), [])
  const setLang = useCallback((next: Lang) => setLangState(next), [])
  const toggleLang = useCallback(() => setLangState((l) => (l === 'en' ? 'ru' : 'en')), [])

  const t = useCallback<SettingsContextValue['t']>(
    (key, params) => {
      const dict = translations[lang] ?? translations.en
      const raw = dict[key] ?? translations.en[key] ?? key
      return interpolate(raw, params)
    },
    [lang],
  )

  const value = useMemo<SettingsContextValue>(
    () => ({
      theme,
      setTheme,
      toggleTheme,
      lang,
      setLang,
      toggleLang,
      t,
    }),
    [theme, lang, t, setTheme, toggleTheme, setLang, toggleLang],
  )

  return <SettingsContext.Provider value={value}>{children}</SettingsContext.Provider>
}

export function useSettings(): SettingsContextValue {
  const ctx = useContext(SettingsContext)
  if (!ctx) throw new Error('useSettings must be used inside <SettingsProvider>')
  return ctx
}

/** Shortcut: const t = useT() */
export function useT() {
  return useSettings().t
}
