import { useCallback, useEffect, useMemo, useRef, useState, type ReactNode } from 'react'
import { useNavigate } from 'react-router-dom'
import { IconSearch } from '../Icons'
import { useT, useSettings } from '../../i18n/SettingsContext'
import CommandResults from './CommandResults'
import { buildPaletteResults } from './commandPaletteUtils'
import type { ResultItem } from './commandPaletteTypes'
import { useBodyScrollLock } from './useBodyScrollLock'
import { usePaletteData } from './usePaletteData'

interface PaletteProps {
  onClose: () => void
}

export default function Palette({ onClose }: PaletteProps) {
  const navigate = useNavigate()
  const t = useT()
  const { lang } = useSettings()
  const inputRef = useRef<HTMLInputElement | null>(null)

  const [query, setQuery] = useState('')
  const [activeIdx, setActiveIdx] = useState(0)
  const { services, bookings, loading } = usePaletteData()

  useBodyScrollLock()

  // Auto-focus input on mount.
  useEffect(() => {
    inputRef.current?.focus()
  }, [])

  const results = useMemo<ResultItem[]>(
    () => buildPaletteResults({ query, services, bookings, lang, t }),
    [query, services, bookings, lang, t],
  )

  // Reset active index when results change.
  useEffect(() => {
    setActiveIdx(0)
  }, [results])

  const goTo = useCallback(
    (to: string) => {
      onClose()
      navigate(to)
    },
    [navigate, onClose],
  )

  const pickItem = useCallback(
    (item: ResultItem) => {
      goTo(item.to)
    },
    [goTo],
  )

  const onKeyDown = (e: React.KeyboardEvent) => {
    if (e.key === 'Escape') {
      e.preventDefault()
      onClose()
      return
    }
    if (results.length === 0) return

    if (e.key === 'ArrowDown') {
      e.preventDefault()
      setActiveIdx((i) => (i + 1) % results.length)
    } else if (e.key === 'ArrowUp') {
      e.preventDefault()
      setActiveIdx((i) => (i - 1 + results.length) % results.length)
    } else if (e.key === 'Enter') {
      e.preventDefault()
      const item = results[activeIdx]
      if (item) pickItem(item)
    }
  }

  return (
    <div
      onMouseDown={(e) => {
        if (e.target === e.currentTarget) onClose()
      }}
      style={{
        position: 'fixed',
        inset: 0,
        zIndex: 150,
        background: 'rgba(0,0,0,0.5)',
        display: 'flex',
        justifyContent: 'center',
        padding: '15vh var(--s-4) var(--s-4)',
      }}
    >
      <div
        role="dialog"
        aria-modal="true"
        aria-label="Command palette"
        onKeyDown={onKeyDown}
        style={{
          width: '100%',
          maxWidth: 600,
          maxHeight: '70vh',
          background: 'var(--bg-elev-1)',
          border: '1px solid var(--border)',
          borderRadius: 'var(--r-lg)',
          boxShadow: 'var(--shadow-md)',
          display: 'flex',
          flexDirection: 'column',
          overflow: 'hidden',
        }}
      >
        <div
          style={{
            display: 'flex',
            alignItems: 'center',
            gap: 'var(--s-3)',
            padding: 'var(--s-4) var(--s-5)',
            borderBottom: '1px solid var(--border)',
          }}
        >
          <IconSearch style={{ color: 'var(--text-muted)' }} />
          <input
            ref={inputRef}
            type="search"
            value={query}
            onChange={(e) => setQuery(e.target.value)}
            placeholder={t('palette.placeholder')}
            style={{
              flex: 1,
              border: 'none',
              outline: 'none',
              background: 'none',
              color: 'var(--text)',
              fontSize: 15,
            }}
          />
        </div>

        <CommandResults
          query={query}
          loading={loading}
          results={results}
          activeIdx={activeIdx}
          onPick={pickItem}
          onHover={setActiveIdx}
        />

        <PaletteFooter />
      </div>
    </div>
  )
}

function PaletteFooter() {
  const t = useT()

  return (
    <div
      style={{
        display: 'flex',
        gap: 'var(--s-4)',
        justifyContent: 'flex-end',
        padding: 'var(--s-3) var(--s-5)',
        borderTop: '1px solid var(--border)',
        fontSize: 11,
        color: 'var(--text-subtle)',
      }}
    >
      <span>
        <Kbd>↑↓</Kbd> {t('palette.hint.navigate')}
      </span>
      <span>
        <Kbd>↵</Kbd> {t('palette.hint.select')}
      </span>
      <span>
        <Kbd>Esc</Kbd> {t('palette.hint.close')}
      </span>
    </div>
  )
}

function Kbd({ children }: { children: ReactNode }) {
  return (
    <span
      style={{
        fontFamily: 'var(--font-mono)',
        background: 'var(--bg-elev-2)',
        padding: '1px 5px',
        borderRadius: 4,
        border: '1px solid var(--border)',
        marginRight: 4,
      }}
    >
      {children}
    </span>
  )
}
