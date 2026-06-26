import { Link, useNavigate } from 'react-router-dom'
import { useState, type FormEvent } from 'react'
import { Button, Field } from '../components/UI'
import { useT } from '../i18n/SettingsContext'
import { useAuth } from '../i18n/AuthContext'
import { AuthError } from '../data/authApi'
import { useToast } from '../components/Toast'
import AuthShell from '../components/auth/AuthShell'
import FieldError from '../components/service-form/FieldError'

const EMAIL_RE = /^[^@\s]+@[^@\s]+\.[^@\s]+$/

type Errors = Partial<Record<'name' | 'email' | 'password' | 'passwordConfirm', string>>

export default function Register() {
  const navigate = useNavigate()
  const t = useT()
  const { register } = useAuth()
  const toast = useToast()

  const [name, setName] = useState('')
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [passwordConfirm, setPasswordConfirm] = useState('')
  const [errors, setErrors] = useState<Errors>({})
  const [submitting, setSubmitting] = useState(false)

  const validate = (): Errors => {
    const e: Errors = {}
    if (!name.trim()) e.name = t('validation.required')
    if (!email.trim()) e.email = t('validation.required')
    else if (!EMAIL_RE.test(email.trim())) e.email = t('validation.email')
    if (!password) e.password = t('validation.required')
    else if (password.length < 6) e.password = t('register.error.passwordShort')
    if (password !== passwordConfirm) e.passwordConfirm = t('register.error.passwordMismatch')
    return e
  }

  const submit = async (ev: FormEvent<HTMLFormElement>) => {
    ev.preventDefault()
    if (submitting) return
    const errs = validate()
    setErrors(errs)
    if (Object.keys(errs).length > 0) return

    setSubmitting(true)
    try {
      await register({ name: name.trim(), email: email.trim(), password })
      navigate('/dashboard', { replace: true })
    } catch (err) {
      if (err instanceof AuthError) {
        // json-server-auth returns 400 with "Email already exists"
        if (err.status === 400 && /already exists/i.test(err.message)) {
          toast.error(t('register.error.emailExists'))
        } else {
          toast.error(err.message)
        }
      } else {
        toast.error(t('login.error.server'))
      }
    } finally {
      setSubmitting(false)
    }
  }

  return (
    <AuthShell
      title={t('register.title')}
      subtitle={t('register.subtitle')}
      footer={
        <>
          {t('register.haveAccount')}{' '}
          <Link to="/login" className="btn-text">
            {t('register.signIn')}
          </Link>
        </>
      }
    >
      <form onSubmit={submit} noValidate>
        <Field label={t('register.name')}>
          <input
            className="input"
            autoComplete="name"
            value={name}
            onChange={(e) => setName(e.target.value)}
            aria-invalid={!!errors.name}
          />
          {errors.name && <FieldError>{errors.name}</FieldError>}
        </Field>

        <Field label={t('login.email')}>
          <input
            className="input"
            type="email"
            autoComplete="email"
            value={email}
            onChange={(e) => setEmail(e.target.value)}
            aria-invalid={!!errors.email}
          />
          {errors.email && <FieldError>{errors.email}</FieldError>}
        </Field>

        <Field label={t('register.password')}>
          <input
            className="input"
            type="password"
            autoComplete="new-password"
            value={password}
            onChange={(e) => setPassword(e.target.value)}
            aria-invalid={!!errors.password}
          />
          {errors.password && <FieldError>{errors.password}</FieldError>}
        </Field>

        <Field label={t('register.passwordConfirm')}>
          <input
            className="input"
            type="password"
            autoComplete="new-password"
            value={passwordConfirm}
            onChange={(e) => setPasswordConfirm(e.target.value)}
            aria-invalid={!!errors.passwordConfirm}
          />
          {errors.passwordConfirm && <FieldError>{errors.passwordConfirm}</FieldError>}
        </Field>

        <Button size="lg" block type="submit" disabled={submitting}>
          {submitting ? t('register.submitting') : t('register.submit')}
        </Button>
      </form>
    </AuthShell>
  )
}
