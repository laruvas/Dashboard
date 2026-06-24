import type { Service, ServicePayload } from '../../types'
import type { TKey } from '../../i18n/translations'
import type { ServiceFormErrors, ServiceFormValues } from './serviceFormTypes'

export const EMPTY_SERVICE_FORM: ServiceFormValues = {
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

type TFn = (key: TKey, params?: Record<string, string | number>) => string

export function toServiceFormValues(service: Service | null): ServiceFormValues {
  if (!service) return EMPTY_SERVICE_FORM
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

export function toServicePayload(values: ServiceFormValues): ServicePayload {
  return {
    tag: { en: String(values.tagEn).trim(), ru: String(values.tagRu).trim() },
    tone: values.tone,
    duration: Number(values.duration),
    price: Number(values.price),
    name: { en: String(values.nameEn).trim(), ru: String(values.nameRu).trim() },
    description: { en: String(values.descEn).trim(), ru: String(values.descRu).trim() },
  }
}

export function validateServiceForm(values: ServiceFormValues, t: TFn): ServiceFormErrors {
  const errors: ServiceFormErrors = {}
  if (!String(values.tagEn).trim()) errors.tagEn = t('validation.required')
  if (!String(values.tagRu).trim()) errors.tagRu = t('validation.required')
  if (!String(values.nameEn).trim()) errors.nameEn = t('validation.required')
  if (!String(values.nameRu).trim()) errors.nameRu = t('validation.required')
  if (!String(values.descEn).trim()) errors.descEn = t('validation.required')
  if (!String(values.descRu).trim()) errors.descRu = t('validation.required')

  const duration = Number(values.duration)
  if (!Number.isFinite(duration) || duration <= 0) errors.duration = t('validation.positiveNumber')

  const price = Number(values.price)
  if (!Number.isFinite(price) || price < 0) errors.price = t('validation.nonNegativeNumber')

  return errors
}
