// Promise-based confirm dialog. Replaces native confirm().
// Usage:
//   const ok = await confirmDialog({ title, message, danger: true })
//   if (!ok) return
//
// Must be wrapped in <ConfirmProvider> at app root.
import { createContext, useCallback, useContext, useState, type ReactNode } from 'react'
import Modal from './Modal'
import { Button } from './UI'
import { useT } from '../i18n/SettingsContext'

export interface ConfirmOptions {
  title: ReactNode
  message?: ReactNode
  confirmText?: ReactNode
  cancelText?: ReactNode
  danger?: boolean
}

type Resolver = (ok: boolean) => void

interface ConfirmContextValue {
  ask: (opts: ConfirmOptions) => Promise<boolean>
}

const ConfirmContext = createContext<ConfirmContextValue | null>(null)

// Module-level resolver — lets non-React code (rare) and module functions call it.
// We also expose a hook for typical usage.
let externalAsk: ConfirmContextValue['ask'] | null = null

export function confirmDialog(opts: ConfirmOptions): Promise<boolean> {
  if (!externalAsk) {
    // Safe fallback during SSR / before provider mounts
    return Promise.resolve(window.confirm(typeof opts.title === 'string' ? opts.title : 'Confirm?'))
  }
  return externalAsk(opts)
}

interface PendingState {
  opts: ConfirmOptions
  resolver: Resolver
}

export function ConfirmProvider({ children }: { children: ReactNode }) {
  const t = useT()
  const [pending, setPending] = useState<PendingState | null>(null)

  const ask = useCallback<ConfirmContextValue['ask']>((opts) => {
    return new Promise<boolean>((resolve) => {
      setPending({ opts, resolver: resolve })
    })
  }, [])

  // Expose to module-level helper
  externalAsk = ask

  const resolve = (ok: boolean) => {
    if (pending) {
      pending.resolver(ok)
      setPending(null)
    }
  }

  const opts = pending?.opts

  return (
    <ConfirmContext.Provider value={{ ask }}>
      {children}
      <Modal
        open={pending !== null}
        onClose={() => resolve(false)}
        title={opts?.title ?? ''}
      >
        {opts?.message && (
          <div style={{ fontSize: 14, color: 'var(--text-muted)', marginBottom: 'var(--s-6)' }}>
            {opts.message}
          </div>
        )}
        <div className="flex flex-gap-3" style={{ justifyContent: 'flex-end' }}>
          <Button variant="ghost" onClick={() => resolve(false)}>
            {opts?.cancelText ?? t('common.cancel')}
          </Button>
          <Button
            onClick={() => resolve(true)}
            style={opts?.danger ? { background: 'var(--danger)' } : undefined}
          >
            {opts?.confirmText ?? t('common.confirm')}
          </Button>
        </div>
      </Modal>
    </ConfirmContext.Provider>
  )
}

export function useConfirm() {
  const ctx = useContext(ConfirmContext)
  if (!ctx) throw new Error('useConfirm must be used inside <ConfirmProvider>')
  return ctx.ask
}
