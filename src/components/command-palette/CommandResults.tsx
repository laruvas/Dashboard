import type { ReactNode } from 'react'
import { SkeletonList } from '../Skeleton'
import { useT } from '../../i18n/SettingsContext'
import type { ResultItem } from './commandPaletteTypes'
import { splitResultGroups } from './commandPaletteUtils'

interface CommandResultsProps {
  query: string
  loading: boolean
  results: ResultItem[]
  activeIdx: number
  onPick: (item: ResultItem) => void
  onHover: (idx: number) => void
}

export default function CommandResults({
  query,
  loading,
  results,
  activeIdx,
  onPick,
  onHover,
}: CommandResultsProps) {
  const t = useT()
  const { serviceItems, bookingItems } = splitResultGroups(results)

  return (
    <div style={{ overflowY: 'auto', flex: 1, padding: 'var(--s-2) 0' }}>
      {loading && query && <SkeletonList count={4} />}

      {!loading && !query && (
        <div className="empty" style={{ padding: 'var(--s-8)' }}>
          {t('palette.empty.start')}
        </div>
      )}

      {!loading && query && results.length === 0 && (
        <div className="empty" style={{ padding: 'var(--s-8)' }}>
          {t('palette.empty.noResults')}
        </div>
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
                    onClick={() => onPick(item)}
                    onHover={() => onHover(idx)}
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
                    onClick={() => onPick(item)}
                    onHover={() => onHover(idx)}
                  />
                )
              })}
            </Group>
          )}
        </>
      )}
    </div>
  )
}

function Group({ title, children }: { title: ReactNode; children: ReactNode }) {
  return (
    <div style={{ marginBottom: 'var(--s-2)' }}>
      <div
        style={{
          padding: 'var(--s-2) var(--s-5)',
          fontFamily: 'var(--font-mono)',
          fontSize: 11,
          color: 'var(--text-subtle)',
          textTransform: 'uppercase',
          letterSpacing: '0.06em',
        }}
      >
        {title}
      </div>
      {children}
    </div>
  )
}

function ResultRow({
  item,
  active,
  onClick,
  onHover,
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
        display: 'block',
        width: '100%',
        textAlign: 'left',
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
