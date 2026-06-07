// Small UI primitives reused across pages.
import type { ButtonHTMLAttributes, AnchorHTMLAttributes, ReactNode, CSSProperties } from 'react'
import { Link } from 'react-router-dom'
import type { PillTone } from '../types'

/* ============ Button ============ */

type ButtonVariant = 'primary' | 'ghost' | 'text'
type ButtonSize = 'sm' | 'lg'

interface ButtonCommonProps {
  variant?: ButtonVariant
  size?: ButtonSize
  block?: boolean
  className?: string
  children?: ReactNode
}

// Discriminated union: when as="link", `to` is required and HTML attrs are <a>'s.
type ButtonAsButton = ButtonCommonProps & {
  as?: 'button'
  to?: never
} & Omit<ButtonHTMLAttributes<HTMLButtonElement>, keyof ButtonCommonProps>

type ButtonAsLink = ButtonCommonProps & {
  as: 'link'
  to: string
} & Omit<AnchorHTMLAttributes<HTMLAnchorElement>, keyof ButtonCommonProps | 'href'>

export type ButtonProps = ButtonAsButton | ButtonAsLink

export function Button(props: ButtonProps) {
  const { variant = 'primary', size, block, className = '', children } = props
  const cls = [
    'btn',
    `btn-${variant}`,
    size && `btn-${size}`,
    block && 'btn-block',
    className,
  ].filter(Boolean).join(' ')

  if (props.as === 'link') {
    const { as: _as, to, variant: _v, size: _s, block: _b, className: _c, children: _ch, ...rest } = props
    void _as; void _v; void _s; void _b; void _c; void _ch
    return <Link to={to} className={cls} {...rest}>{children}</Link>
  }
  const { as: _as, variant: _v, size: _s, block: _b, className: _c, children: _ch, ...rest } = props
  void _as; void _v; void _s; void _b; void _c; void _ch
  return <button className={cls} {...rest}>{children}</button>
}

/* ============ Pill ============ */

interface PillProps {
  tone?: PillTone
  className?: string
  children?: ReactNode
}

export function Pill({ tone = 'muted', className = '', children, ...rest }: PillProps) {
  return <span className={`pill pill-${tone} ${className}`.trim()} {...rest}>{children}</span>
}

/* ============ Card ============ */

interface CardCommonProps {
  interactive?: boolean
  className?: string
  style?: CSSProperties
  children?: ReactNode
}

type CardAsDiv = CardCommonProps & {
  as?: 'div'
  to?: never
  onClick?: (e: React.MouseEvent<HTMLDivElement>) => void
}

type CardAsLink = CardCommonProps & {
  as: 'link'
  to: string
}

export type CardProps = CardAsDiv | CardAsLink

export function Card(props: CardProps) {
  const { interactive, className = '', style, children } = props
  const cls = ['card', interactive && 'card-interactive', className].filter(Boolean).join(' ')

  if (props.as === 'link') {
    return <Link to={props.to} className={cls} style={style}>{children}</Link>
  }
  return (
    <div className={cls} style={style} onClick={props.onClick}>
      {children}
    </div>
  )
}

/* ============ Stat ============ */

interface StatProps {
  label: string
  value: ReactNode
  delta?: string
  down?: boolean
}

export function Stat({ label, value, delta, down }: StatProps) {
  return (
    <div className="stat">
      <span className="label">{label}</span>
      <span className="value">{value}</span>
      {delta && <span className={`delta ${down ? 'down' : ''}`}>{delta}</span>}
    </div>
  )
}

/* ============ Field ============ */

interface FieldProps {
  label: ReactNode
  children: ReactNode
}

export function Field({ label, children }: FieldProps) {
  return (
    <div className="field">
      <label>{label}</label>
      {children}
    </div>
  )
}

/* ============ Avatar ============ */

interface AvatarProps {
  initials?: string
  size?: number
}

export function Avatar({ initials = '?', size = 32 }: AvatarProps) {
  return (
    <div
      className="avatar"
      style={{ width: size, height: size, fontSize: Math.max(10, Math.round(size * 0.36)) }}
    >
      {initials}
    </div>
  )
}

/* ============ Divider ============ */

export function Divider() {
  return <div className="divider" />
}

/* ============ LabelMono ============ */

export function LabelMono({ children }: { children: ReactNode }) {
  return <span className="label-mono">{children}</span>
}

/* ============ Tabs ============ */

export interface TabItem<V extends string = string> {
  value: V
  label: ReactNode
  count?: number
}

interface TabsProps<V extends string = string> {
  items: TabItem<V>[]
  value: V
  onChange?: (v: V) => void
}

export function Tabs<V extends string = string>({ items, value, onChange }: TabsProps<V>) {
  return (
    <div className="tabs">
      {items.map((it) => (
        <button
          key={it.value}
          className={`tab ${value === it.value ? 'active' : ''}`}
          onClick={() => onChange?.(it.value)}
        >
          {it.label}
          {it.count != null && <span className="text-subtle mono" style={{ marginLeft: 6 }}>{it.count}</span>}
        </button>
      ))}
    </div>
  )
}
