import type { TKey } from '../../i18n/translations'
import type { CustomerForm, DetailsErrors } from './bookingTypes'

const EMAIL_RE = /^[^@\s]+@[^@\s]+\.[^@\s]+$/
const PHONE_RE = /^[+\d\s()-]{6,}$/

type TFn = (key: TKey, params?: Record<string, string | number>) => string

export function validateDetails(values: CustomerForm, t: TFn): DetailsErrors {
  const errors: DetailsErrors = {}
  if (!values.name.trim()) errors.name = t('validation.required')
  if (!values.email.trim()) errors.email = t('validation.required')
  else if (!EMAIL_RE.test(values.email.trim())) errors.email = t('validation.email')
  if (values.phone.trim() && !PHONE_RE.test(values.phone.trim()))
    errors.phone = t('validation.phone')
  return errors
}
