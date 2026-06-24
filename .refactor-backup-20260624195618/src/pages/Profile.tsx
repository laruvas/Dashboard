import { useState, type ChangeEvent, type FormEvent } from 'react'
import { useNavigate } from 'react-router-dom'
import { Button, Card, Field, Avatar } from '../components/UI'
import { useT, useSettings } from '../i18n/SettingsContext'
import { useAuth } from '../i18n/AuthContext'
import { useToast } from '../components/Toast'
import { useConfirm } from '../components/Confirm'
import { DAY_KEYS, type DayKey, type DayHours, type Lang, type Theme, type WorkingHours } from '../types'

interface ProfileForm {
  fullName: string
  displayName: string
  email: string
  phone: string
  timezone: string
  bio: string
  workingHours: WorkingHours
}

const DEFAULT_WH: WorkingHours = {
  mon: { start: '09:00', end: '18:00' },
  tue: { start: '09:00', end: '18:00' },
  wed: { start: '09:00', end: '18:00' },
  thu: { start: '09:00', end: '18:00' },
  fri: { start: '09:00', end: '18:00' },
}

/**
 * Backwards-compat: old User.workingHours was {start, end} (one window for all days).
 * Spread into Mon-Fri so existing users don't lose data on first edit.
 */
function normalizeWH(wh: WorkingHours | { start?: string; end?: string } | undefined): WorkingHours {
  if (!wh) return DEFAULT_WH
  const legacy = wh as { start?: string; end?: string }
  if (typeof legacy.start === 'string' && typeof legacy.end === 'string') {
    const w = { start: legacy.start, end: legacy.end }
    return { mon: w, tue: w, wed: w, thu: w, fri: w }
  }
  const newShape = wh as WorkingHours
  // Recovery: if every day is null or missing (e.g. user accidentally disabled
  // all days, or a buggy save wiped the object), restore defaults so they don't
  // end up with no availability at all.
  const hasAnyDay = DAY_KEYS.some(k => newShape[k])
  if (!hasAnyDay) return DEFAULT_WH
  // Fill in missing (undefined) days from DEFAULT_WH so partially-saved profiles
  // show all days the server actually treats as working. Explicit `null` stays —
  // that's the user's intent ("day off").
  const filled: WorkingHours = { ...newShape }
  for (const k of DAY_KEYS) {
    if (!(k in filled)) filled[k] = DEFAULT_WH[k] ?? null
  }
  return filled
}

export default function Profile() {
  const t = useT()
  const toast = useToast()
  const confirm = useConfirm()
  const navigate = useNavigate()
  const { user, logout, updateProfile } = useAuth()
  const [saving, setSaving] = useState(false)
  const { lang, setLang, theme, setTheme } = useSettings()

  const handleLogout = async () => {
    const ok = await confirm({
      title: t('auth.logout'),
      confirmText: t('auth.logout'),
      danger: true,
    })
    if (!ok) return
    logout()
    toast.success(t('auth.loggedOut'))
    navigate('/login', { replace: true })
  }

  const [form, setForm] = useState<ProfileForm>(() => ({
    fullName: user?.name || '',
    displayName: user?.displayName || user?.name?.split(' ')[0] || '',
    email: user?.email || '',
    phone: user?.phone || '',
    timezone: user?.timezone || 'Europe/Moscow (GMT+3)',
    bio: user?.bio || '',
    workingHours: normalizeWH(user?.workingHours),
  }))
  const upd = (k: keyof ProfileForm) =>
    (e: ChangeEvent<HTMLInputElement | HTMLTextAreaElement | HTMLSelectElement>) => {
      setForm({ ...form, [k]: e.target.value })
    }

  const save = async (e: FormEvent<HTMLFormElement>) => {
    e.preventDefault()
    if (saving) return
    setSaving(true)
    try {
      await updateProfile({
        name: form.fullName.trim(),
        displayName: form.displayName.trim() || undefined,
        email: form.email.trim(),
        phone: form.phone.trim() || undefined,
        timezone: form.timezone || undefined,
        bio: form.bio.trim() || undefined,
        workingHours: form.workingHours,
      })
      toast.success(t('profile.saved'))
    } catch {
      toast.error(t('profile.saveError'))
    } finally {
      setSaving(false)
    }
  }

  return (
    <>
      <h1 className="mb-2">{t('profile.title')}</h1>
      <p className="subtitle mb-8">{t('profile.subtitle')}</p>

      <div style={{ maxWidth: 880 }}>
        <form onSubmit={save}>
          <Card className="mb-6">
            <h3 className="mb-4">{t('profile.section.profile')}</h3>
            <div className="flex flex-gap-4 mb-6" style={{ alignItems: 'center' }}>
              <Avatar
                initials={
                  (form.displayName || form.fullName || '?')
                    .trim().split(/\s+/).slice(0, 2)
                    .map(w => w[0]?.toUpperCase() || '').join('') || '?'
                }
                size={64}
              />
              <div>
                <div style={{ fontWeight: 600 }}>{form.displayName || form.fullName || '—'}</div>
                <div className="text-muted mt-2" style={{ fontSize: 13 }}>{form.email || ''}</div>
              </div>
            </div>
            <div className="grid grid-2">
              <Field label={t('profile.field.fullName')}><input className="input" value={form.fullName} onChange={upd('fullName')} /></Field>
              <Field label={t('profile.field.displayName')}><input className="input" value={form.displayName} onChange={upd('displayName')} /></Field>
              <Field label={t('profile.field.email')}><input className="input" value={form.email} onChange={upd('email')} /></Field>
              <Field label={t('profile.field.phone')}><input className="input" value={form.phone} onChange={upd('phone')} /></Field>
              <Field label={t('profile.field.timezone')}>
                <select className="select" value={form.timezone} onChange={upd('timezone')}>
                  <option>Europe/Moscow (GMT+3)</option>
                  <option>America/New_York (GMT-4)</option>
                  <option>Europe/London (GMT+1)</option>
                </select>
              </Field>
              <Field label={t('profile.field.language')}>
                <select
                  className="select"
                  value={lang}
                  onChange={(e) => setLang(e.target.value as Lang)}
                >
                  <option value="en">English</option>
                  <option value="ru">Русский</option>
                </select>
              </Field>
            </div>
            <Field label={t('profile.field.bio')}>
              <textarea className="textarea" value={form.bio} onChange={upd('bio')} />
            </Field>
          </Card>

          <Card className="mb-6">
            <h3 className="mb-4">{lang === 'ru' ? 'Внешний вид' : 'Appearance'}</h3>
            <Field label={lang === 'ru' ? 'Тема' : 'Theme'}>
              <select
                className="select"
                value={theme}
                onChange={(e) => setTheme(e.target.value as Theme)}
              >
                <option value="dark">{lang === 'ru' ? 'Тёмная' : 'Dark'}</option>
                <option value="light">{lang === 'ru' ? 'Светлая' : 'Light'}</option>
              </select>
            </Field>
          </Card>

          <Card className="mb-6">
            <h3 className="mb-4">{t('profile.workingHours')}</h3>
            <p className="text-muted mb-4" style={{ fontSize: 13 }}>{t('profile.workingHoursHint')}</p>
            <WorkingHoursEditor
              value={form.workingHours}
              onChange={(wh) => setForm({ ...form, workingHours: wh })}
            />
          </Card>

          <div className="flex-between" style={{ alignItems: 'center' }}>
            <Button
              variant="ghost"
              type="button"
              onClick={handleLogout}
              style={{ color: 'var(--danger)' }}
            >
              {t('auth.logout')}
            </Button>
            <div className="flex flex-gap-3" style={{ alignItems: 'center' }}>
              <Button variant="ghost" type="button" disabled={saving}>{t('common.cancel')}</Button>
              <Button type="submit" disabled={saving}>
                {saving ? t('common.loading') : t('common.save')}
              </Button>
            </div>
          </div>
        </form>
      </div>
    </>
  )
}

/* ============== WorkingHoursEditor ============== */

interface WorkingHoursEditorProps {
  value: WorkingHours
  onChange: (next: WorkingHours) => void
}

function WorkingHoursEditor({ value, onChange }: WorkingHoursEditorProps) {
  const t = useT()

  // Last non-null window per day — restored when the user re-enables a day they toggled off.
  // Falls back to 09:00-18:00 for never-set days.
  const fallback: DayHours = { start: '09:00', end: '18:00' }

  const updateDay = (key: DayKey, next: DayHours | null) => {
    onChange({ ...value, [key]: next })
  }

  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: 8 }}>
      {DAY_KEYS.map((key) => {
        const day = value[key]
        const enabled = day != null
        const eff = day ?? fallback
        return (
          <div key={key} style={{
            display: 'grid',
            gridTemplateColumns: '110px auto 1fr 1fr',
            alignItems: 'center',
            gap: 12,
          }}>
            <label className="flex flex-gap-2" style={{ alignItems: 'center', cursor: 'pointer' }}>
              <input
                type="checkbox"
                checked={enabled}
                onChange={(e) => updateDay(key, e.target.checked ? eff : null)}
              />
              <span style={{ fontWeight: 500 }}>{t(`day.${key}` as Parameters<typeof t>[0])}</span>
            </label>
            <span className="text-muted" style={{ fontSize: 12 }}>
              {enabled ? '' : t('profile.dayOff')}
            </span>
            <input
              className="input mono"
              type="time"
              value={eff.start}
              disabled={!enabled}
              onChange={(e) => updateDay(key, { ...eff, start: e.target.value })}
            />
            <input
              className="input mono"
              type="time"
              value={eff.end}
              disabled={!enabled}
              onChange={(e) => updateDay(key, { ...eff, end: e.target.value })}
            />
          </div>
        )
      })}
    </div>
  )
}
