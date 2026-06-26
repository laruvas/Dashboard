import { useState, type ChangeEvent, type FormEvent, type ReactNode } from 'react'
import { Button, Field } from '../../components/UI'
import { useT } from '../../i18n/SettingsContext'
import type { CustomerForm, DetailsErrors } from './bookingTypes'
import { validateDetails } from './bookingValidation'

interface DetailsFormProps {
  defaultValues: CustomerForm
  onSubmit: (data: CustomerForm) => void
  onBack: () => void
}

export default function DetailsForm({ defaultValues, onSubmit, onBack }: DetailsFormProps) {
  const t = useT()
  const [values, setValues] = useState<CustomerForm>(defaultValues)
  const [errors, setErrors] = useState<DetailsErrors>({})
  const [touched, setTouched] = useState<Partial<Record<keyof CustomerForm, boolean>>>({})

  const setField =
    (k: keyof CustomerForm) => (e: ChangeEvent<HTMLInputElement | HTMLTextAreaElement>) => {
      const v = e.target.value
      setValues((prev) => ({ ...prev, [k]: v }))
      if (touched[k] || errors[k]) {
        setErrors(validateDetails({ ...values, [k]: v }, t))
      }
    }

  const markTouched = (k: keyof CustomerForm) => () => {
    setTouched((prev) => ({ ...prev, [k]: true }))
    setErrors(validateDetails(values, t))
  }

  const submit = (e: FormEvent<HTMLFormElement>) => {
    e.preventDefault()
    const errs = validateDetails(values, t)
    setErrors(errs)
    setTouched({ name: true, email: true, phone: true })
    if (Object.keys(errs).length === 0) {
      onSubmit({
        name: values.name.trim(),
        email: values.email.trim(),
        phone: values.phone.trim(),
        notes: values.notes.trim(),
      })
    }
  }

  return (
    <form onSubmit={submit} noValidate style={{ maxWidth: 560 }}>
      <h3 className="mb-6">{t('booking.yourDetails')}</h3>

      <Field label={t('booking.field.name')}>
        <input
          className="input"
          autoComplete="name"
          value={values.name}
          onChange={setField('name')}
          onBlur={markTouched('name')}
          aria-invalid={!!errors.name}
        />
        {errors.name && <FieldError>{errors.name}</FieldError>}
      </Field>

      <Field label={t('booking.field.email')}>
        <input
          className="input"
          type="email"
          autoComplete="email"
          value={values.email}
          onChange={setField('email')}
          onBlur={markTouched('email')}
          aria-invalid={!!errors.email}
        />
        {errors.email && <FieldError>{errors.email}</FieldError>}
      </Field>

      <Field label={t('booking.field.phone')}>
        <input
          className="input"
          type="tel"
          autoComplete="tel"
          value={values.phone}
          onChange={setField('phone')}
          onBlur={markTouched('phone')}
          aria-invalid={!!errors.phone}
        />
        {errors.phone && <FieldError>{errors.phone}</FieldError>}
      </Field>

      <Field label={t('booking.field.notes')}>
        <textarea
          className="textarea"
          placeholder={t('booking.field.notes.ph')}
          value={values.notes}
          onChange={setField('notes')}
        />
      </Field>

      <div className="flex flex-gap-3 mt-4">
        <Button variant="ghost" type="button" onClick={onBack}>
          {t('common.back')}
        </Button>
        <Button type="submit">{t('common.continue')}</Button>
      </div>
    </form>
  )
}

function FieldError({ children }: { children: ReactNode }) {
  return <span style={{ color: 'var(--danger)', fontSize: 12, marginTop: 4 }}>{children}</span>
}
