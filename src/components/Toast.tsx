// Lightweight toast notifications.
// Usage:
//   const toast = useToast()
//   toast.success('Saved')
//   toast.error('Failed to load')
//   toast.info('Reminder set')
//
// Must be wrapped in <ToastProvider> at app root.
import { createContext, useCallback, useContext, useEffect, useState, type ReactNode } from 'react'

type ToastKind = 'success' | 'error' | 'info'

interface ToastItem {
  id: number
  kind: ToastKind
  message: ReactNode
}

interface ToastApi {
  success: (message: ReactNode) => void
  error: (message: ReactNode) => void
  info: (message: ReactNode) => void
}

const ToastContext = createContext<ToastApi | null>(null)

const DURATION_MS = 4000
let counter = 0

export function ToastProvider({ children }: { children: ReactNode }) {
  const [items, setItems] = useState<ToastItem[]>([])

  const push = useCallback((kind: ToastKind, message: ReactNode) => {
    const id = ++counter
    setItems((prev) => [...prev, { id, kind, message }])
    setTimeout(() => {
      setItems((prev) => prev.filter((t) => t.id !== id))
    }, DURATION_MS)
  }, [])

  const api: ToastApi = {
    success: (m) => push('success', m),
    error: (m) => push('error', m),
    info: (m) => push('info', m),
  }

  return (
    <ToastContext.Provider value={api}>
      {children}
      <ToastContainer
        items={items}
        onDismiss={(id) => setItems((prev) => prev.filter((t) => t.id !== id))}
      />
    </ToastContext.Provider>
  )
}

export function useToast(): ToastApi {
  const ctx = useContext(ToastContext)
  if (!ctx) throw new Error('useToast must be used inside <ToastProvider>')
  return ctx
}

function ToastContainer({
  items,
  onDismiss,
}: {
  items: ToastItem[]
  onDismiss: (id: number) => void
}) {
  return (
    <div
      role="region"
      aria-label="Notifications"
      style={{
        position: 'fixed',
        bottom: 'var(--s-6)',
        right: 'var(--s-6)',
        zIndex: 200,
        display: 'flex',
        flexDirection: 'column',
        gap: 'var(--s-2)',
        maxWidth: 360,
      }}
    >
      {items.map((t) => (
        <ToastView key={t.id} item={t} onDismiss={() => onDismiss(t.id)} />
      ))}
    </div>
  )
}

function ToastView({ item, onDismiss }: { item: ToastItem; onDismiss: () => void }) {
  // Fade-in on mount
  const [shown, setShown] = useState(false)
  useEffect(() => {
    const id = requestAnimationFrame(() => setShown(true))
    return () => cancelAnimationFrame(id)
  }, [])

  const colorByKind: Record<ToastKind, string> = {
    success: 'var(--success)',
    error: 'var(--danger)',
    info: 'var(--accent)',
  }

  return (
    <div
      role="status"
      onClick={onDismiss}
      style={{
        background: 'var(--bg-elev-2)',
        border: '1px solid var(--border)',
        borderLeft: `3px solid ${colorByKind[item.kind]}`,
        borderRadius: 'var(--r-md)',
        padding: 'var(--s-3) var(--s-4)',
        boxShadow: 'var(--shadow-md)',
        fontSize: 13.5,
        color: 'var(--text)',
        cursor: 'pointer',
        opacity: shown ? 1 : 0,
        transform: shown ? 'translateY(0)' : 'translateY(8px)',
        transition: 'opacity .2s, transform .2s',
      }}
    >
      {item.message}
    </div>
  )
}
