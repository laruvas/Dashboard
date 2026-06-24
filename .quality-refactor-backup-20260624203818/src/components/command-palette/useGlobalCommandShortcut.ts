import { useEffect } from 'react'
import { isCommandK, isTypingTarget } from './commandPaletteUtils'

export function useGlobalCommandShortcut(onOpen: () => void): void {
  useEffect(() => {
    const onKey = (e: KeyboardEvent) => {
      if (!isCommandK(e)) return
      // Don't hijack if user is typing in an input/textarea.
      if (isTypingTarget(e.target)) return
      e.preventDefault()
      onOpen()
    }

    window.addEventListener('keydown', onKey)
    return () => window.removeEventListener('keydown', onKey)
  }, [onOpen])
}
