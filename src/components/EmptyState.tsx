// EmptyState — unified empty/zero-data UI with an illustration.
// Usage:
//   <EmptyState
//     illustration="calendar"
//     title={t('bookings.empty.title')}
//     description={t('bookings.empty.text')}
//     action={<Button as="link" to="/booking">+ New booking</Button>}
//   />
import type { ComponentType, ReactNode } from 'react'

type IllustrationKind = 'calendar' | 'services' | 'search' | 'bell'

interface EmptyStateProps {
  illustration?: IllustrationKind
  title: ReactNode
  description?: ReactNode
  action?: ReactNode
}

export default function EmptyState({ illustration, title, description, action }: EmptyStateProps) {
  return (
    <div className="empty-state">
      {illustration && <Illustration kind={illustration} />}
      <div className="title">{title}</div>
      {description && <div className="description">{description}</div>}
      {action}
    </div>
  )
}

/* ============== Illustrations ==============
   Thin-line SVG matching the app aesthetic.
   Colour comes from currentColor → text-subtle by default.
*/

function Illustration({ kind }: { kind: IllustrationKind }) {
  const Comp = ILLUSTRATIONS[kind]
  return (
    <div className="illustration" aria-hidden="true">
      <Comp />
    </div>
  )
}

const baseSvg = {
  width: 120,
  height: 120,
  viewBox: '0 0 120 120',
  fill: 'none',
  stroke: 'currentColor',
  strokeWidth: 1.5,
  strokeLinecap: 'round' as const,
  strokeLinejoin: 'round' as const,
}

function CalendarIllustration() {
  return (
    <svg {...baseSvg}>
      {/* Calendar body */}
      <rect x="20" y="30" width="80" height="70" rx="6" />
      {/* Top binding */}
      <line x1="20" y1="48" x2="100" y2="48" />
      {/* Rings */}
      <line x1="40" y1="22" x2="40" y2="38" />
      <line x1="80" y1="22" x2="80" y2="38" />
      {/* Subtle "empty" hint — dotted dashes inside */}
      <line x1="32" y1="62" x2="48" y2="62" strokeDasharray="2 4" opacity="0.5" />
      <line x1="32" y1="74" x2="64" y2="74" strokeDasharray="2 4" opacity="0.5" />
      <line x1="32" y1="86" x2="56" y2="86" strokeDasharray="2 4" opacity="0.5" />
    </svg>
  )
}

function ServicesIllustration() {
  return (
    <svg {...baseSvg}>
      {/* Shelf-like grid of cards */}
      <rect x="20" y="28" width="36" height="28" rx="3" />
      <rect x="64" y="28" width="36" height="28" rx="3" />
      <rect x="20" y="64" width="36" height="28" rx="3" />
      <rect x="64" y="64" width="36" height="28" rx="3" strokeDasharray="3 4" opacity="0.5" />
      {/* Tiny lines inside the first three */}
      <line x1="26" y1="38" x2="40" y2="38" opacity="0.6" />
      <line x1="26" y1="46" x2="48" y2="46" opacity="0.4" />
      <line x1="70" y1="38" x2="84" y2="38" opacity="0.6" />
      <line x1="70" y1="46" x2="92" y2="46" opacity="0.4" />
      <line x1="26" y1="74" x2="40" y2="74" opacity="0.6" />
      <line x1="26" y1="82" x2="48" y2="82" opacity="0.4" />
    </svg>
  )
}

function SearchIllustration() {
  return (
    <svg {...baseSvg}>
      {/* Magnifying glass */}
      <circle cx="52" cy="52" r="26" />
      <line x1="72" y1="72" x2="92" y2="92" />
      {/* Empty inside — three dots */}
      <circle cx="44" cy="52" r="1.5" fill="currentColor" opacity="0.6" />
      <circle cx="52" cy="52" r="1.5" fill="currentColor" opacity="0.6" />
      <circle cx="60" cy="52" r="1.5" fill="currentColor" opacity="0.6" />
    </svg>
  )
}

function BellIllustration() {
  return (
    <svg {...baseSvg}>
      {/* Bell */}
      <path d="M40 80 L80 80 C82 80 84 78 82 75 C76 68 76 60 76 52 C76 40 68 32 60 32 C52 32 44 40 44 52 C44 60 44 68 38 75 C36 78 38 80 40 80 Z" />
      {/* Clapper */}
      <path d="M54 80 C54 84 56 88 60 88 C64 88 66 84 66 80" />
      {/* Top */}
      <line x1="60" y1="28" x2="60" y2="32" />
      {/* "Empty" hint — soft dashes */}
      <path d="M30 96 L90 96" strokeDasharray="2 4" opacity="0.5" />
    </svg>
  )
}

const ILLUSTRATIONS: Record<IllustrationKind, ComponentType> = {
  calendar: CalendarIllustration,
  services: ServicesIllustration,
  search:   SearchIllustration,
  bell:     BellIllustration,
}
