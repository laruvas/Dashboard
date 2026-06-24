import { useEffect } from 'react'

export function useBodyScrollLock(): void {
  useEffect(() => {
    const prevFocused = document.activeElement
    document.body.style.overflow = 'hidden'

    return () => {
      document.body.style.overflow = ''
      if (prevFocused instanceof HTMLElement) prevFocused.focus()
    }
  }, [])
}
