import { useState, type ChangeEvent, type FormEvent } from 'react'
import { Button } from './UI'
import { useT } from '../i18n/SettingsContext'
import type { Service, ServicePayload } from '../types'
import ServiceBasicsFields from './service-form/ServiceBasicsFields'
import ServiceDetailsFields from './service-form/ServiceDetailsFields'
import type {
  ServiceFormErrors,
  ServiceFormTouched,
  ServiceFormValues,
} from './service-form/serviceFormTypes'
import {
  toServiceFormValues,
  toServicePayload,
  validateServiceForm,
} from './service-form/serviceFormUtils'

interface ServiceFormProps {
  service: Service | null
  onSubmit: (payload: ServicePayload) => void
  onCancel: () => void
  saving?: boolean
}

export default function ServiceForm({
  service,
  onSubmit,
  onCancel,
  saving = false,
}: ServiceFormProps) {
  const t = useT()
  const [values, setValues] = useState<ServiceFormValues>(() => toServiceFormValues(service))
  const [errors, setErrors] = useState<ServiceFormErrors>({})
  const [touched, setTouched] = useState<ServiceFormTouched>({})

  const setField =
    (key: keyof ServiceFormValues) =>
    (e: ChangeEvent<HTMLInputElement | HTMLTextAreaElement | HTMLSelectElement>) => {
      const value = e.target.value
      setValues((prev) => {
        const next = { ...prev, [key]: value }
        if (touched[key] || errors[key]) setErrors(validateServiceForm(next, t))
        return next
      })
    }

  const markTouched = (key: keyof ServiceFormValues) => () => {
    setTouched((prev) => ({ ...prev, [key]: true }))
    setErrors(validateServiceForm(values, t))
  }

  const submit = (e: FormEvent<HTMLFormElement>) => {
    e.preventDefault()
    const nextErrors = validateServiceForm(values, t)
    setErrors(nextErrors)
    setTouched({
      tagEn: true,
      tagRu: true,
      nameEn: true,
      nameRu: true,
      descEn: true,
      descRu: true,
      duration: true,
      price: true,
    })
    if (Object.keys(nextErrors).length === 0) onSubmit(toServicePayload(values))
  }

  return (
    <form onSubmit={submit} noValidate>
      <ServiceBasicsFields
        values={values}
        errors={errors}
        setField={setField}
        markTouched={markTouched}
      />

      <ServiceDetailsFields
        values={values}
        errors={errors}
        setField={setField}
        markTouched={markTouched}
      />

      <div className="flex flex-gap-3 mt-4" style={{ justifyContent: 'flex-end' }}>
        <Button variant="ghost" type="button" onClick={onCancel} disabled={saving}>
          {t('common.cancel')}
        </Button>
        <Button type="submit" disabled={saving}>
          {saving ? t('common.loading') : service ? t('common.save') : t('serviceForm.create')}
        </Button>
      </div>
    </form>
  )
}
