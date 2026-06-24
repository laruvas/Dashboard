import type { ReactNode } from 'react'

export default function FieldError({ children }: { children: ReactNode }) {
  return <span style={{ color: 'var(--danger)', fontSize: 12, marginTop: 4 }}>{children}</span>
}
