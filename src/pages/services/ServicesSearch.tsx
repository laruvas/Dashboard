import SearchBox from '../../components/SearchBox'
import { useT } from '../../i18n/SettingsContext'

interface ServicesSearchProps {
  query: string
  onQueryChange: (query: string) => void
}

export default function ServicesSearch({ query, onQueryChange }: ServicesSearchProps) {
  const t = useT()

  return (
    <SearchBox
      value={query}
      onChange={onQueryChange}
      placeholder={t('services.search.placeholder')}
    />
  )
}
