import { useState, type ChangeEvent, type FormEvent, type ReactNode } from 'react'
import { Button, Field } from './UI'
import { useT } from '../i18n/SettingsContext'
import type { Service, ServicePayload, PillTone } from '../types'

interface FormValues {
  tagEn: string
  tagRu: string
  tone: PillTone
  duration: number | string
  price: number | string
  nameEn: string
  nameRu: string
  descEn: string
  descRu: string
}

type FormErrors = Partial<Record<keyof FormValues, string>>
type Touched = Partial<Record<keyof FormValues, boolean>>

const EMPTY: FormValues = {
  tagEn: '',
  tagRu: '',
  tone: 'muted',
  duration: 60,
  price: 50,
  nameEn: '',
  nameRu: '',
  descEn: '',
  descRu: '',
}

function toFormValues(service: Service | null): FormValues {
  if (!service) return EMPTY
  return {
    tagEn: service.tag?.en || '',
    tagRu: service.tag?.ru || '',
    tone: service.tone || 'muted',
    duration: service.duration ?? 60,
    price: service.price ?? 50,
    nameEn: service.name?.en || '',
    nameRu: service.name?.ru || '',
    descEn: service.description?.en || '',
    descRu: service.description?.ru || '',
  }
}

function toPayload(v: FormValues): ServicePayload {
  return {
    tag: { en: String(v.tagEn).trim(), ru: String(v.tagRu).trim() },
    tone: v.tone,
    duration: Number(v.duration),
    price: Number(v.price),
    name: { en: String(v.nameEn).trim(), ru: String(v.nameRu).trim() },
    description: { en: String(v.descEn).trim(), ru: String(v.descRu).trim() },
  }
}

type TFn = ReturnType<typeof useT>

function validate(v: FormValues, t: TFn): FormErrors {
  const errors: FormErrors = {}
  if (!String(v.tagEn).trim()) errors.tagEn = t('validation.required')
  if (!String(v.tagRu).trim()) errors.tagRu = t('validation.required')
  if (!String(v.nameEn).trim()) errors.nameEn = t('validation.required')
  if (!String(v.nameRu).trim()) errors.nameRu = t('validation.required')
  if (!String(v.descEn).trim()) errors.descEn = t('validation.required')
  if (!String(v.descRu).trim()) errors.descRu = t('validation.required')
  const dur = Number(v.duration)
  if (!Number.isFinite(dur) || dur <= 0) errors.duration = t('validation.positiveNumber')
  const price = Number(v.price)
  if (!Number.isFinite(price) || price < 0) errors.price = t('validation.nonNegativeNumber')
  return errors
}

interface ServiceFormProps {
  service: Service | null
  onSubmit: (payload: ServicePayload) => void
  onCancel: () => void
  saving?: boolean
}

export default function ServiceForm({ service, onSubmit, onCancel, saving = false }: ServiceFormProps) {
  const t = useT()
  const [values, setValues] = useState<FormValues>(() => toFormValues(service))
  const [errors, setErrors] = useState<FormErrors>({})
  const [touched, setTouched] = useState<Touched>({})

  const setField = (k: keyof FormValues) =>
    (e: ChangeEvent<HTMLInputElement | HTMLTextAreaElement | HTMLSelectElement>) => {
      const v = e.target.value
      setValues(prev => {
        const next = { ...prev, [k]: v }
        if (touched[k] || errors[k]) setErrors(validate(next, t))
        return next
      })
    }

  const markTouched = (k: keyof FormValues) => () => {
    setTouched(prev => ({ ...prev, [k]: true }))
    setErrors(validate(values, t))
  }

  const submit = (e: FormEvent<HTMLFormElement>) => {
    e.preventDefault()
    const errs = validate(values, t)
    setErrors(errs)
    setTouched({
      tagEn: true, tagRu: true, nameEn: true, nameRu: true,
      descEn: true, descRu: true, duration: true, price: true,
    })
    if (Object.keys(errs).length === 0) onSubmit(toPayload(values))
  }

  return (
    <form onSubmit={submit} noValidate>
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

      <div className="flex flex-gap-3 mt-4" style={{ justifyContent: 'flex-end' }}>
        <Button variant="ghost" type="button" onClick={onCancel} disabled={saving}>{t('common.cancel')}</Button>
        <Button type="submit" disabled={saving}>
          {saving ? t('common.loading') : (service ? t('common.save') : t('serviceForm.create'))}
        </Button>
      </div>
    </form>
  )
}

function FieldError({ children }: { children: ReactNode }) {
  return <span style={{ color: 'var(--danger)', fontSize: 12, marginTop: 4 }}>{children}</span>
}
