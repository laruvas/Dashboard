export type Step = 1 | 2 | 3 | 4

export interface CustomerForm {
  name: string
  email: string
  phone: string
  notes: string
}

export type DetailsErrors = Partial<Record<keyof CustomerForm, string>>
