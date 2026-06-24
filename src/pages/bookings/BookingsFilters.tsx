import { Tabs, type TabItem } from '../../components/UI'
import { IconSearch } from '../../components/Icons'
import { useT } from '../../i18n/SettingsContext'
import type { StatusTab } from './bookingsTypes'

interface BookingsFiltersProps {
  tabs: TabItem<StatusTab>[]
  status: StatusTab
  query: string
  onStatusChange: (status: StatusTab) => void
  onQueryChange: (query: string) => void
}

export default function BookingsFilters({
  tabs,
  status,
  query,
  onStatusChange,
  onQueryChange,
}: BookingsFiltersProps) {
  const t = useT()

  return (
    <>
      <Tabs items={tabs} value={status} onChange={onStatusChange} />
      <div
        className="mb-4"
        style={{
          background: 'var(--bg-elev-1)',
          border: '1px solid var(--border)',
          borderRadius: 'var(--r-md)',
          padding: 'var(--s-2) var(--s-3)',
          display: 'flex', alignItems: 'center', gap: 'var(--s-2)',
          maxWidth: 420,
        }}
      >
        <IconSearch style={{ color: 'var(--text-muted)' }} />
        <input
          type="search"
          value={query}
          onChange={(e) => onQueryChange(e.target.value)}
          placeholder={t('bookings.search.placeholder')}
          style={{
            flex: 1, border: 'none', outline: 'none', background: 'none',
            color: 'var(--text)', fontSize: 13,
          }}
        />
      </div>
    </>
  )
}
