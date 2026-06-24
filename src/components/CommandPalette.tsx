// Global command palette (⌘K / Ctrl+K).
// Searches services + bookings, keyboard navigation, jumps to detail pages.
//
// Usage:
//   <CommandPaletteProvider>
//     <App />
//   </CommandPaletteProvider>
//
//   const { open } = useCommandPalette()
//   open()  // programmatically

import { createContext, useCallback, useContext, useMemo, useState, type ReactNode } from 'react'
import Palette from './command-palette/Palette'
import { useGlobalCommandShortcut } from './command-palette/useGlobalCommandShortcut'
import type { CommandPaletteContextValue } from './command-palette/commandPaletteTypes'

const CommandPaletteContext = createContext<CommandPaletteContextValue | null>(null)

export function CommandPaletteProvider({ children }: { children: ReactNode }) {
  const [isOpen, setOpen] = useState(false)

  const open = useCallback(() => setOpen(true), [])
  const close = useCallback(() => setOpen(false), [])

  useGlobalCommandShortcut(open)

  const value = useMemo<CommandPaletteContextValue>(() => ({ open, close }), [open, close])

  return (
    <CommandPaletteContext.Provider value={value}>
      {children}
      {isOpen && <Palette onClose={close} />}
    </CommandPaletteContext.Provider>
  )
}

export function useCommandPalette(): CommandPaletteContextValue {
  const ctx = useContext(CommandPaletteContext)
  if (!ctx) throw new Error('useCommandPalette must be used inside <CommandPaletteProvider>')
  return ctx
}
