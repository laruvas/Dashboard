// Landing page shown at "/". Always renders the marketing pitch — even for
// authenticated users — so they can land here from a bookmark / logo click
// without getting bounced. Authenticated visitors see a "Go to dashboard" CTA
// instead of "Sign in / Create account".
import { Link } from 'react-router-dom'
import { Button } from '../components/UI'
import { ThemeToggle, LangToggle } from '../components/Toggles'
import { useT } from '../i18n/SettingsContext'
import { useAuth } from '../i18n/AuthContext'

export default function Welcome() {
  const t = useT()
  const { isAuthenticated } = useAuth()

  return (
    <div
      style={{
        minHeight: '100vh',
        display: 'grid',
        gridTemplateRows: 'auto 1fr auto',
        padding: 'var(--s-8)',
        background: 'var(--bg)',
        color: 'var(--text)',
      }}
    >
      {/* Header — logo + toggles */}
      <header className="flex-between">
        <Link
          to="/"
          className="flex flex-gap-3"
          style={{ alignItems: 'center', fontWeight: 700, fontSize: 16 }}
        >
          <span
            style={{
              width: 28,
              height: 28,
              borderRadius: 7,
              background: 'var(--accent)',
              display: 'grid',
              placeItems: 'center',
              color: '#fff',
              fontWeight: 800,
            }}
          >
            S
          </span>
          Slottr
        </Link>
        <div className="flex flex-gap-2">
          <LangToggle />
          <ThemeToggle />
        </div>
      </header>

      {/* Hero — centred */}
      <main
        style={{
          display: 'grid',
          placeItems: 'center',
          padding: 'var(--s-8) 0',
        }}
      >
        <div style={{ maxWidth: 520, textAlign: 'center' }}>
          <h1
            style={{
              fontSize: 'clamp(36px, 6vw, 56px)',
              fontWeight: 700,
              letterSpacing: '-0.03em',
              lineHeight: 1.1,
              marginBottom: 'var(--s-4)',
            }}
          >
            {t('welcome.tagline')}
          </h1>
          <p
            style={{
              fontSize: 17,
              color: 'var(--text-muted)',
              lineHeight: 1.55,
              marginBottom: 'var(--s-8)',
            }}
          >
            {t('welcome.description')}
          </p>

          <div className="flex flex-gap-3" style={{ justifyContent: 'center' }}>
            {isAuthenticated ? (
              <Button as="link" to="/dashboard" size="lg">
                {t('welcome.openDashboard')}
              </Button>
            ) : (
              <>
                <Button as="link" to="/login" size="lg">
                  {t('welcome.signIn')}
                </Button>
                <Button as="link" to="/register" size="lg" variant="ghost">
                  {t('welcome.createAccount')}
                </Button>
              </>
            )}
          </div>
        </div>
      </main>

      {/* Footer */}
      <footer
        style={{
          textAlign: 'center',
          fontSize: 12,
          color: 'var(--text-subtle)',
        }}
      >
        {t('welcome.footer')}
      </footer>
    </div>
  )
}
