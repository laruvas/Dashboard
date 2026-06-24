import { Tabs, type TabItem } from '../../components/UI'
import SearchBox from '../../components/SearchBox'
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
      <SearchBox
        className="mb-4"
        value={query}
        onChange={onQueryChange}
        placeholder={t('bookings.search.placeholder')}
      />
    </>
  )
}
