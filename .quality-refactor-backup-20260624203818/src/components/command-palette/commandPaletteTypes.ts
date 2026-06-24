export interface CommandPaletteContextValue {
  open: () => void
  close: () => void
}

export interface ResultItem {
  id: string
  group: 'services' | 'bookings'
  title: string
  subtitle: string
  to: string
}
