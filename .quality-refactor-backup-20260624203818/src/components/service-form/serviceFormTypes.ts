import type { PillTone } from '../../types'

export interface ServiceFormValues {
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

export type ServiceFormErrors = Partial<Record<keyof ServiceFormValues, string>>
export type ServiceFormTouched = Partial<Record<keyof ServiceFormValues, boolean>>
