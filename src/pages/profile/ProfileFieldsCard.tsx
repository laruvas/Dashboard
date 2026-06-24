import type { ChangeEvent } from 'react'
import { Avatar, Card, Field } from '../../components/UI'
import { useT } from '../../i18n/SettingsContext'
import type { Lang } from '../../types'
import type { ProfileFormValues } from './profileTypes'
import { getInitials } from './profileUtils'

interface ProfileFieldsCardProps {
  form: ProfileFormValues
  lang: Lang
  onFieldChange: (key: keyof ProfileFormValues) => (e: ChangeEvent<HTMLInputElement | HTMLTextAreaElement | HTMLSelectElement>) => void
  onLangChange: (lang: Lang) => void
}

export default function ProfileFieldsCard({ form, lang, onFieldChange, onLangChange }: ProfileFieldsCardProps) {
  const t = useT()

  return (
    <Card className="mb-6">
      <h3 className="mb-4">{t('profile.section.profile')}</h3>
      <div className="flex flex-gap-4 mb-6" style={{ alignItems: 'center' }}>
        <Avatar initials={getInitials(form.displayName || form.fullName || '?')} size={64} />
        <div>
          <div style={{ fontWeight: 600 }}>{form.displayName || form.fullName || '—'}</div>
          <div className="text-muted mt-2" style={{ fontSize: 13 }}>{form.email || ''}</div>
        </div>
      </div>

      <div className="grid grid-2">
        <Field label={t('profile.field.fullName')}><input className="input" value={form.fullName} onChange={onFieldChange('fullName')} /></Field>
        <Field label={t('profile.field.displayName')}><input className="input" value={form.displayName} onChange={onFieldChange('displayName')} /></Field>
        <Field label={t('profile.field.email')}><input className="input" value={form.email} onChange={onFieldChange('email')} /></Field>
        <Field label={t('profile.field.phone')}><input className="input" value={form.phone} onChange={onFieldChange('phone')} /></Field>
        <Field label={t('profile.field.timezone')}>
          <select className="select" value={form.timezone} onChange={onFieldChange('timezone')}>
            <option>Europe/Moscow (GMT+3)</option>
            <option>America/New_York (GMT-4)</option>
            <option>Europe/London (GMT+1)</option>
          </select>
        </Field>
        <Field label={t('profile.field.language')}>
          <select
            className="select"
            value={lang}
            onChange={(e) => onLangChange(e.target.value as Lang)}
          >
            <option value="en">English</option>
            <option value="ru">Русский</option>
          </select>
        </Field>
      </div>

      <Field label={t('profile.field.bio')}>
        <textarea className="textarea" value={form.bio} onChange={onFieldChange('bio')} />
      </Field>
    </Card>
  )
}
