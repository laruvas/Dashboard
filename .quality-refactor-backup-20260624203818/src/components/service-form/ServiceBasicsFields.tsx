import type { ChangeEvent } from 'react'
import { Field } from '../UI'
import { useT } from '../../i18n/SettingsContext'
import type { ServiceFormErrors, ServiceFormValues } from './serviceFormTypes'
import FieldError from './FieldError'

interface ServiceBasicsFieldsProps {
  values: ServiceFormValues
  errors: ServiceFormErrors
  setField: (key: keyof ServiceFormValues) => (e: ChangeEvent<HTMLInputElement | HTMLTextAreaElement | HTMLSelectElement>) => void
  markTouched: (key: keyof ServiceFormValues) => () => void
}

export default function ServiceBasicsFields({ values, errors, setField, markTouched }: ServiceBasicsFieldsProps) {
  const t = useT()

  return (
    <div className="grid grid-2">
      <Field label={t('serviceForm.tag.en')}>
        <input
          className="input"
          value={values.tagEn}
          onChange={setField('tagEn')}
          onBlur={markTouched('tagEn')}
          aria-invalid={!!errors.tagEn}
          placeholder="Strategy, Consultation, ..."
        />
        {errors.tagEn && <FieldError>{errors.tagEn}</FieldError>}
      </Field>

      <Field label={t('serviceForm.tag.ru')}>
        <input
          className="input"
          value={values.tagRu}
          onChange={setField('tagRu')}
          onBlur={markTouched('tagRu')}
          aria-invalid={!!errors.tagRu}
          placeholder="Стратегия, Консультация, ..."
        />
        {errors.tagRu && <FieldError>{errors.tagRu}</FieldError>}
      </Field>

      <Field label={t('serviceForm.name.en')}>
        <input
          className="input"
          value={values.nameEn}
          onChange={setField('nameEn')}
          onBlur={markTouched('nameEn')}
          aria-invalid={!!errors.nameEn}
        />
        {errors.nameEn && <FieldError>{errors.nameEn}</FieldError>}
      </Field>

      <Field label={t('serviceForm.name.ru')}>
        <input
          className="input"
          value={values.nameRu}
          onChange={setField('nameRu')}
          onBlur={markTouched('nameRu')}
          aria-invalid={!!errors.nameRu}
        />
        {errors.nameRu && <FieldError>{errors.nameRu}</FieldError>}
      </Field>

      <Field label={t('serviceForm.duration')}>
        <input
          className="input"
          type="number"
          min={1}
          value={values.duration}
          onChange={setField('duration')}
          onBlur={markTouched('duration')}
          aria-invalid={!!errors.duration}
        />
        {errors.duration && <FieldError>{errors.duration}</FieldError>}
      </Field>

      <Field label={t('serviceForm.price')}>
        <input
          className="input"
          type="number"
          min={0}
          value={values.price}
          onChange={setField('price')}
          onBlur={markTouched('price')}
          aria-invalid={!!errors.price}
        />
        {errors.price && <FieldError>{errors.price}</FieldError>}
      </Field>
    </div>
  )
}
