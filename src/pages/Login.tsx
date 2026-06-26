import { Link, useNavigate, useLocation } from 'react-router-dom'
import { useState, type FormEvent } from 'react'
import { Button, Field } from '../components/UI'
import { useT } from '../i18n/SettingsContext'
import { useAuth } from '../i18n/AuthContext'
import { AuthError } from '../data/authApi'
import { useToast } from '../components/Toast'
import AuthShell from '../components/auth/AuthShell'

interface LocationState {
  from?: { pathname?: string }
}

export default function Login() {
  const navigate = useNavigate()
  const location = useLocation()
  const t = useT()
  const { login } = useAuth()
  const toast = useToast()
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [submitting, setSubmitting] = useState(false)

  // Where to send the user after successful login.
  // Fallback to /dashboard, avoid bouncing back to /login.
  const state = location.state as LocationState | null
  const fromPath = state?.from?.pathname
  const redirectTo = fromPath && fromPath !== '/login' ? fromPath : '/dashboard'

  const submit = async (e: FormEvent<HTMLFormElement>) => {
    e.preventDefault()
    if (submitting) return
    setSubmitting(true)
    try {
      await login({ email: email.trim(), password })
      navigate(redirectTo, { replace: true })
    } catch (err) {
      if (err instanceof AuthError) {
        toast.error(err.status === 400 ? t('login.error.invalid') : err.message)
      } else {
        toast.error(t('login.error.server'))
      }
    } finally {
      setSubmitting(false)
    }
  }

  return (
    <AuthShell
      title={t('login.welcome')}
      subtitle={t('login.subtitle')}
      footer={
        <>
          {t('login.noAccount')}{' '}
          <Link to="/register" className="btn-text">
            {t('login.signUp')}
          </Link>
        </>
      }
    >
      <form onSubmit={submit}>
        <Field label={t('login.email')}>
          <input
            className="input"
            type="email"
            value={email}
            onChange={(e) => setEmail(e.target.value)}
          />
        </Field>
        <Field label={t('login.password')}>
          <input
            className="input"
            type="password"
            value={password}
            onChange={(e) => setPassword(e.target.value)}
          />
        </Field>

        <div className="flex-between mb-6" style={{ fontSize: 13 }}>
          <label
            className="flex flex-gap-2 text-muted"
            style={{ alignItems: 'center', cursor: 'pointer' }}
          >
            <input type="checkbox" defaultChecked /> {t('login.remember')}
          </label>
          <Link to="#" className="btn-text">
            {t('login.forgot')}
          </Link>
        </div>

        <Button size="lg" block type="submit" disabled={submitting}>
          {submitting ? t('login.signingIn') : t('login.signIn')}
        </Button>

        <div className="flex flex-gap-3" style={{ alignItems: 'center', margin: 'var(--s-6) 0' }}>
          <div style={{ flex: 1, height: 1, background: 'var(--border)' }} />
          <span className="text-subtle" style={{ fontSize: 12 }}>
            {t('login.or')}
          </span>
          <div style={{ flex: 1, height: 1, background: 'var(--border)' }} />
        </div>

        <Button variant="ghost" size="lg" block type="button" className="mb-2">
          {t('login.google')}
        </Button>
        <Button variant="ghost" size="lg" block type="button">
          {t('login.apple')}
        </Button>
      </form>
    </AuthShell>
  )
}
