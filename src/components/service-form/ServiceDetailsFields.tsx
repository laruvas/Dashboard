import type { ChangeEvent } from 'react'
import { Field } from '../UI'
import { useT } from '../../i18n/SettingsContext'
import type { ServiceFormErrors, ServiceFormValues } from './serviceFormTypes'
import FieldError from './FieldError'

interface ServiceDetailsFieldsProps {
  values: ServiceFormValues
  errors: ServiceFormErrors
  setField: (key: keyof ServiceFormValues) => (e: ChangeEvent<HTMLInputElement | HTMLTextAreaElement | HTMLSelectElement>) => void
  markTouched: (key: keyof ServiceFormValues) => () => void
}

export default function ServiceDetailsFields({ values, errors, setField, markTouched }: ServiceDetailsFieldsProps) {
  const t = useT()

  return (
    <>
      <Field label={t('serviceForm.tone')}>
        <select className="select" value={values.tone} onChange={setField('tone')}>
          <option value="muted">{t('serviceForm.tone.muted')}</option>
          <option value="accent">{t('serviceForm.tone.accent')}</option>
        </select>
      </Field>

      <Field label={t('serviceForm.desc.en')}>
        <textarea
          className="textarea"
          value={values.descEn}
          onChange={setField('descEn')}
          onBlur={markTouched('descEn')}
          aria-invalid={!!errors.descEn}
        />
        {errors.descEn && <FieldError>{errors.descEn}</FieldError>}
      </Field>

      <Field label={t('serviceForm.desc.ru')}>
        <textarea
          className="textarea"
          value={values.descRu}
          onChange={setField('descRu')}
          onBlur={markTouched('descRu')}
          aria-invalid={!!errors.descRu}
        />
        {errors.descRu && <FieldError>{errors.descRu}</FieldError>}
      </Field>
    </>
  )
}
