import { useEffect, useRef, type ReactNode } from 'react'

interface ModalProps {
  open: boolean
  onClose: () => void
  title: ReactNode
  children: ReactNode
  footer?: ReactNode
}

/**
 * Accessible modal dialog.
 * - Esc to close
 * - Click on overlay to close
 * - Body scroll locked while open
 * - Focus moves to first focusable on open, restores on close
 * - role="dialog" + aria-modal + aria-labelledby
 */
export default function Modal({ open, onClose, title, children, footer }: ModalProps) {
  const ref = useRef<HTMLDivElement | null>(null)
  const previouslyFocused = useRef<Element | null>(null)

  useEffect(() => {
    if (!open) return

    previouslyFocused.current = document.activeElement
    document.body.style.overflow = 'hidden'

    const onKey = (e: KeyboardEvent) => {
      if (e.key === 'Escape') onClose()
    }
    window.addEventListener('keydown', onKey)

    // Move focus to first focusable element inside the modal
    const first = ref.current?.querySelector<HTMLElement>(
      'input, select, textarea, button, [tabindex]:not([tabindex="-1"])',
    )
    first?.focus()

    return () => {
      window.removeEventListener('keydown', onKey)
      document.body.style.overflow = ''
      if (previouslyFocused.current instanceof HTMLElement) {
        previouslyFocused.current.focus()
      }
    }
  }, [open, onClose])

  if (!open) return null

  return (
    <div
      // Close on click (not mousedown) so text-selection drags that end on the
      // overlay don't accidentally dismiss the modal mid-edit.
      onClick={(e) => {
        if (e.target === e.currentTarget) onClose()
      }}
      style={{
        position: 'fixed',
        inset: 0,
        zIndex: 100,
        background: 'rgba(0,0,0,0.5)',
        display: 'grid',
        placeItems: 'center',
        padding: 'var(--s-4)',
      }}
    >
      <div
        ref={ref}
        role="dialog"
        aria-modal="true"
        aria-labelledby="modal-title"
        className="card"
        style={{
          width: '100%',
          maxWidth: 640,
          maxHeight: '90vh',
          overflowY: 'auto',
          padding: 0,
          background: 'var(--bg-elev-1)',
        }}
      >
        <div
          style={{
            padding: 'var(--s-5) var(--s-6)',
            borderBottom: '1px solid var(--border)',
            display: 'flex',
            justifyContent: 'space-between',
            alignItems: 'center',
          }}
        >
          <h3 id="modal-title">{title}</h3>
          <button
            onClick={onClose}
            aria-label="Close"
            style={{ fontSize: 20, color: 'var(--text-muted)', padding: '0 var(--s-2)' }}
          >
            ×
          </button>
        </div>

        <div style={{ padding: 'var(--s-6)' }}>{children}</div>

        {footer && (
          <div
            style={{
              padding: 'var(--s-4) var(--s-6)',
              borderTop: '1px solid var(--border)',
              display: 'flex',
              gap: 'var(--s-3)',
              justifyContent: 'flex-end',
            }}
          >
            {footer}
          </div>
        )}
      </div>
    </div>
  )
}
