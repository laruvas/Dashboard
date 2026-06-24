import type { ReactNode } from 'react'
import { Link } from 'react-router-dom'
import { LangToggle, ThemeToggle } from '../Toggles'

interface AuthShellProps {
  title: ReactNode
  subtitle: ReactNode
  footer: ReactNode
  children: ReactNode
}

export default function AuthShell({ title, subtitle, footer, children }: AuthShellProps) {
  return (
    <div className="auth">
      <div style={{ position: 'fixed', top: 16, right: 16, display: 'flex', gap: 8 }}>
        <LangToggle />
        <ThemeToggle />
      </div>

      <div className="auth-card">
        <Link to="/" className="flex flex-gap-3 mb-8" style={{ alignItems: 'center', fontWeight: 700, fontSize: 16 }}>
          <span style={{ width: 28, height: 28, borderRadius: 7, background: 'var(--accent)', display: 'grid', placeItems: 'center', color: '#fff', fontWeight: 800 }}>S</span>
          Slottr
        </Link>

        <h1 className="mb-2" style={{ fontSize: 28 }}>{title}</h1>
        <p className="subtitle mb-8">{subtitle}</p>

        {children}

        <p className="text-muted mt-8" style={{ textAlign: 'center', fontSize: 13 }}>
          {footer}
        </p>
      </div>
    </div>
  )
}
