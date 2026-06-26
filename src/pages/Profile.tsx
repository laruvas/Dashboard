import { useState, type ChangeEvent, type FormEvent } from 'react'
import { useNavigate } from 'react-router-dom'
import { Button } from '../components/UI'
import { useT, useSettings } from '../i18n/SettingsContext'
import { useAuth } from '../i18n/AuthContext'
import { useToast } from '../components/Toast'
import { useConfirm } from '../components/Confirm'
import type { ProfileFormValues } from './profile/profileTypes'
import ProfileFieldsCard from './profile/ProfileFieldsCard'
import AppearanceCard from './profile/AppearanceCard'
import WorkingHoursCard from './profile/WorkingHoursCard'
import { getInitialProfileForm } from './profile/profileUtils'

export default function Profile() {
  const t = useT()
  const toast = useToast()
  const confirm = useConfirm()
  const navigate = useNavigate()
  const { user, logout, updateProfile } = useAuth()
  const { lang, setLang, theme, setTheme } = useSettings()

  const [saving, setSaving] = useState(false)
  const [form, setForm] = useState<ProfileFormValues>(() => getInitialProfileForm(user))

  const updateField =
    (key: keyof ProfileFormValues) =>
    (e: ChangeEvent<HTMLInputElement | HTMLTextAreaElement | HTMLSelectElement>) => {
      setForm((prev) => ({ ...prev, [key]: e.target.value }))
    }

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
          <ProfileFieldsCard
            form={form}
            lang={lang}
            onFieldChange={updateField}
            onLangChange={setLang}
          />

          <AppearanceCard lang={lang} theme={theme} onThemeChange={setTheme} />

          <WorkingHoursCard
            value={form.workingHours}
            onChange={(workingHours) => setForm((prev) => ({ ...prev, workingHours }))}
          />

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
              <Button variant="ghost" type="button" disabled={saving}>
                {t('common.cancel')}
              </Button>
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
