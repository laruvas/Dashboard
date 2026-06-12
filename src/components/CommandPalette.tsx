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
//
// Cmd/Ctrl+K opens it globally, except when focus is inside an input/textarea
// (so it doesn't hijack the user's typing).

import {
  createContext, useCallback, useContext, useEffect, useMemo, useRef, useState,
  type ReactNode,
} from 'react'
import { useNavigate } from 'react-router-dom'
import { IconSearch } from './Icons'
import { SkeletonList } from './Skeleton'
import { listServices } from '../data/servicesApi'
import { listBookings } from '../data/bookingsApi'
import { loc } from '../data/mock'
import { useT, useSettings } from '../i18n/SettingsContext'
import type { Booking, Service } from '../types'

interface CommandPaletteContextValue {
  open: () => void
  close: () => void
}

const CommandPaletteContext = createContext<CommandPaletteContextValue | null>(null)

interface ResultItem {
  id: string
  group: 'services' | 'bookings'
  title: string
  subtitle: string
  to: string
}

export function CommandPaletteProvider({ children }: { children: ReactNode }) {
  const [isOpen, setOpen] = useState(false)
  const value: CommandPaletteContextValue = {
    open: () => setOpen(true),
    close: () => setOpen(false),
  }

  // Global ⌘K / Ctrl+K
  useEffect(() => {
    const onKey = (e: KeyboardEvent) => {
      const isMac = navigator.platform.toUpperCase().includes('MAC')
      const cmd = isMac ? e.metaKey : e.ctrlKey
      if (!cmd || e.key.toLowerCase() !== 'k') return
      // Don't hijack if user is typing in an input/textarea (unless it's our search)
      const target = e.target as HTMLElement | null
      if (target && target.tagName && /^(INPUT|TEXTAREA)$/.test(target.tagName)) return
      e.preventDefault()
      setOpen(true)
    }
    window.addEventListener('keydown', onKey)
    return () => window.removeEventListener('keydown', onKey)
  }, [])

  return (
    <CommandPaletteContext.Provider value={value}>
      {children}
      {isOpen && <Palette onClose={() => setOpen(false)} />}
    </CommandPaletteContext.Provider>
  )
}

export function useCommandPalette(): CommandPaletteContextValue {
  const ctx = useContext(CommandPaletteContext)
  if (!ctx) throw new Error('useCommandPalette must be used inside <CommandPaletteProvider>')
  return ctx
}

/* ============== Palette UI ============== */

function Palette({ onClose }: { onClose: () => void }) {
  const navigate = useNavigate()
  const t = useT()
  const { lang } = useSettings()
  const inputRef = useRef<HTMLInputElement | null>(null)

  const [query, setQuery] = useState('')
  const [services, setServices] = useState<Service[]>([])
  const [bookings, setBookings] = useState<Booking[]>([])
  const [loading, setLoading] = useState(true)
  const [activeIdx, setActiveIdx] = useState(0)

  // Load data on open
  useEffect(() => {
    let mounted = true
    Promise.all([listServices(), listBookings()])
      .then(([s, b]) => {
        if (!mounted) return
        setServices(s)
        setBookings(b)
      })
      .catch(() => { /* silent — palette still usable */ })
      .finally(() => { if (mounted) setLoading(false) })
    return () => { mounted = false }
  }, [])

  // Auto-focus input on mount
  useEffect(() => {
    inputRef.current?.focus()
  }, [])

  // Compute results
  const results = useMemo<ResultItem[]>(() => {
    if (!query.trim()) return []
    const q = query.toLowerCase()
    const items: ResultItem[] = []

    for (const s of services) {
      const haystack = [
        loc(s.name, lang), loc(s.description, lang), loc(s.tag, lang),
        s.name?.en, s.name?.ru, s.tag?.en, s.tag?.ru,
      ].filter(Boolean).join(' ').toLowerCase()
      if (haystack.includes(q)) {
        items.push({
          id: `service-${s.id}`,
          group: 'services',
          title: loc(s.name, lang),
          subtitle: `${loc(s.tag, lang)} · ${s.duration} ${t('services.minutes')} · $${s.price}`,
          to: `/services/${s.id}`,
        })
      }
    }

    for (const b of bookings) {
      const haystack = [
        b.service, b.withName, b.customerEmail, b.customerPhone, b.notes, b.dateISO, b.time,
      ].filter(Boolean).join(' ').toLowerCase()
      if (haystack.includes(q)) {
        items.push({
          id: `booking-${b.id}`,
          group: 'bookings',
          title: `${b.service} — ${b.withName || '—'}`,
          subtitle: `${b.dateISO} · ${b.time}${b.endTime ? `–${b.endTime}` : ''} · ${b.customerEmail}`,
          to: `/bookings/${b.id}`,
        })
      }
    }

    return items.slice(0, 20)
  }, [query, services, bookings, lang, t])

  // Reset active index when results change
  useEffect(() => { setActiveIdx(0) }, [results])

  const goTo = useCallback((to: string) => {
    onClose()
    navigate(to)
  }, [navigate, onClose])

  // Keyboard navigation
  const onKeyDown = (e: React.KeyboardEvent) => {
    if (e.key === 'Escape') { e.preventDefault(); onClose(); return }
    if (results.length === 0) return
    if (e.key === 'ArrowDown') {
      e.preventDefault()
      setActiveIdx(i => (i + 1) % results.length)
    } else if (e.key === 'ArrowUp') {
      e.preventDefault()
      setActiveIdx(i => (i - 1 + results.length) % results.length)
    } else if (e.key === 'Enter') {
      e.preventDefault()
      const item = results[activeIdx]
      if (item) goTo(item.to)
    }
  }

  // Group results
  const serviceItems = results.filter(r => r.group === 'services')
  const bookingItems = results.filter(r => r.group === 'bookings')

  // Body scroll lock + restore focus
  useEffect(() => {
    const prevFocused = document.activeElement
    document.body.style.overflow = 'hidden'
    return () => {
      document.body.style.overflow = ''
      if (prevFocused instanceof HTMLElement) prevFocused.focus()
    }
  }, [])

  return (
    <div
      onMouseDown={(e) => { if (e.target === e.currentTarget) onClose() }}
      style={{
        position: 'fixed', inset: 0, zIndex: 150,
        background: 'rgba(0,0,0,0.5)',
        display: 'flex', justifyContent: 'center',
        padding: '15vh var(--s-4) var(--s-4)',
      }}
    >
      <div
        role="dialog"
        aria-modal="true"
        aria-label="Command palette"
        onKeyDown={onKeyDown}
        style={{
          width: '100%', maxWidth: 600, maxHeight: '70vh',
          background: 'var(--bg-elev-1)',
          border: '1px solid var(--border)',
          borderRadius: 'var(--r-lg)',
          boxShadow: 'var(--shadow-md)',
          display: 'flex', flexDirection: 'column',
          overflow: 'hidden',
        }}
      >
        {/* Search input */}
        <div style={{
          display: 'flex', alignItems: 'center', gap: 'var(--s-3)',
          padding: 'var(--s-4) var(--s-5)',
          borderBottom: '1px solid var(--border)',
        }}>
          <IconSearch style={{ color: 'var(--text-muted)' }} />
          <input
            ref={inputRef}
            type="search"
            value={query}
            onChange={(e) => setQuery(e.target.value)}
            placeholder={t('palette.placeholder')}
            style={{
              flex: 1, border: 'none', outline: 'none', background: 'none',
              color: 'var(--text)', fontSize: 15,
            }}
          />
        </div>

        {/* Results */}
        <div style={{ overflowY: 'auto', flex: 1, padding: 'var(--s-2) 0' }}>
          {loading && query && (
            <SkeletonList count={4} />
          )}

          {!loading && !query && (
            <div className="empty" style={{ padding: 'var(--s-8)' }}>{t('palette.empty.start')}</div>
          )}

          {!loading && query && results.length === 0 && (
            <div className="empty" style={{ padding: 'var(--s-8)' }}>{t('palette.empty.noResults')}</div>
          )}

          {results.length > 0 && (
            <>
              {serviceItems.length > 0 && (
                <Group title={t('palette.group.services')}>
                  {serviceItems.map((item) => {
                    const idx = results.indexOf(item)
                    return (
                      <ResultRow
                        key={item.id}
                        item={item}
                        active={idx === activeIdx}
                        onClick={() => goTo(item.to)}
                        onHover={() => setActiveIdx(idx)}
                      />
                    )
                  })}
                </Group>
              )}
              {bookingItems.length > 0 && (
                <Group title={t('palette.group.bookings')}>
                  {bookingItems.map((item) => {
                    const idx = results.indexOf(item)
                    return (
                      <ResultRow
                        key={item.id}
                        item={item}
                        active={idx === activeIdx}
                        onClick={() => goTo(item.to)}
                        onHover={() => setActiveIdx(idx)}
                      />
                    )
                  })}
                </Group>
              )}
            </>
          )}
        </div>

        {/* Footer hints */}
        <div style={{
          display: 'flex', gap: 'var(--s-4)', justifyContent: 'flex-end',
          padding: 'var(--s-3) var(--s-5)',
          borderTop: '1px solid var(--border)',
          fontSize: 11, color: 'var(--text-subtle)',
        }}>
          <span><Kbd>↑↓</Kbd> {t('palette.hint.navigate')}</span>
          <span><Kbd>↵</Kbd> {t('palette.hint.select')}</span>
          <span><Kbd>Esc</Kbd> {t('palette.hint.close')}</span>
        </div>
      </div>
    </div>
  )
}

function Group({ title, children }: { title: ReactNode; children: ReactNode }) {
  return (
    <div style={{ marginBottom: 'var(--s-2)' }}>
      <div style={{
        padding: 'var(--s-2) var(--s-5)',
        fontFamily: 'var(--font-mono)',
        fontSize: 11,
        color: 'var(--text-subtle)',
        textTransform: 'uppercase',
        letterSpacing: '0.06em',
      }}>{title}</div>
      {children}
    </div>
  )
}

function ResultRow({
  item, active, onClick, onHover,
}: {
  item: ResultItem
  active: boolean
  onClick: () => void
  onHover: () => void
}) {
  return (
    <button
      type="button"
      onClick={onClick}
      onMouseEnter={onHover}
      style={{
        display: 'block', width: '100%', textAlign: 'left',
        padding: 'var(--s-3) var(--s-5)',
        background: active ? 'var(--bg-hover)' : 'transparent',
        color: 'var(--text)',
        cursor: 'pointer',
        borderLeft: `2px solid ${active ? 'var(--accent)' : 'transparent'}`,
      }}
    >
      <div style={{ fontWeight: 500, fontSize: 14 }}>{item.title}</div>
      <div style={{ fontSize: 12, color: 'var(--text-muted)', marginTop: 2 }}>{item.subtitle}</div>
    </button>
  )
}

function Kbd({ children }: { children: ReactNode }) {
  return (
    <span style={{
      fontFamily: 'var(--font-mono)',
      background: 'var(--bg-elev-2)',
      padding: '1px 5px',
      borderRadius: 4,
      border: '1px solid var(--border)',
      marginRight: 4,
    }}>{children}</span>
  )
}
