import { IconSearch } from '../../components/Icons'
import { useT } from '../../i18n/SettingsContext'

interface ServicesSearchProps {
  query: string
  onQueryChange: (query: string) => void
}

export default function ServicesSearch({ query, onQueryChange }: ServicesSearchProps) {
  const t = useT()

  return (
    <div
      className="mb-6"
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
        placeholder={t('services.search.placeholder')}
        style={{
          flex: 1, border: 'none', outline: 'none', background: 'none',
          color: 'var(--text)', fontSize: 13,
        }}
      />
    </div>
  )
}
