import type { Service } from '../../types'

// editing state: null = closed, {__new:true} = create, Service = edit
export type EditingState = Service | { __new: true } | null

export interface ServiceFilterItem {
  value: string
  label: string
  count: number
}

export const isEditingService = (editing: EditingState): editing is Service =>
  editing !== null && !('__new' in editing)
