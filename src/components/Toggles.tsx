import { useSettings } from '../i18n/SettingsContext'
import { IconSun, IconMoon } from './Icons'

export function ThemeToggle() {
  const { theme, toggleTheme, t } = useSettings()
  const isDark = theme === 'dark'
  return (
    <button
      className="btn btn-ghost btn-sm"
      onClick={toggleTheme}
      title={isDark ? t('common.theme.light') : t('common.theme.dark')}
      aria-label={isDark ? t('common.theme.light') : t('common.theme.dark')}
    >
      {isDark ? <IconSun /> : <IconMoon />}
    </button>
  )
}

export function LangToggle() {
  const { lang, toggleLang, t } = useSettings()
  return (
    <button
      className="btn btn-ghost btn-sm"
      onClick={toggleLang}
      title={t('common.lang')}
      aria-label={t('common.lang')}
      style={{ fontFamily: 'var(--font-mono)', fontSize: 12, fontWeight: 600, letterSpacing: '0.04em' }}
    >
      {lang === 'en' ? 'EN' : 'RU'}
    </button>
  )
}
