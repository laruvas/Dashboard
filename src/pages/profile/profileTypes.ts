import type { WorkingHours } from '../../types'

export interface ProfileFormValues {
  fullName: string
  displayName: string
  email: string
  phone: string
  timezone: string
  bio: string
  workingHours: WorkingHours
}
