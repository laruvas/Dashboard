import { Link } from 'react-router-dom'
import { Button, Card, Pill } from '../../components/UI'
import EmptyState from '../../components/EmptyState'
import SearchBox from '../../components/SearchBox'
import { SkeletonCardGrid } from '../../components/Skeleton'
import { loc } from '../../data/mock'
import { useT, useSettings } from '../../i18n/SettingsContext'
import type { Service } from '../../types'
import { matchesServiceQuery } from './bookingUtils'

interface ServiceStepProps {
  services: Service[]
  loading: boolean
  showSkeleton: boolean
  selectedServiceId: string | null
  selectedTag: string
  query: string
  onTagChange: (tag: string) => void
  onQueryChange: (query: string) => void
  onPickService: (id: string) => void
}

export default function ServiceStep({
  services,
  loading,
  showSkeleton,
  selectedServiceId,
  selectedTag,
  query,
  onTagChange,
  onQueryChange,
  onPickService,
}: ServiceStepProps) {
  const t = useT()
  const { lang } = useSettings()

  const matchedAll = services.filter((s) => matchesServiceQuery(s, query, lang))
  const seen = new Map<string, Service['tag']>()
  for (const s of services) {
    const key = s.tag?.en
    if (key && !seen.has(key)) seen.set(key, s.tag)
  }

  const filters = [
    { value: 'all', label: t('services.tab.all'), count: matchedAll.length },
    ...[...seen.entries()].map(([key, tag]) => ({
      value: key,
      label: loc(tag, lang),
      count: matchedAll.filter((s) => s.tag?.en === key).length,
    })),
  ]

  let visible = services
  if (selectedTag !== 'all') visible = visible.filter((s) => s.tag?.en === selectedTag)
  if (query) visible = visible.filter((s) => matchesServiceQuery(s, query, lang))

  const isEmptySearch = !loading && services.length > 0 && visible.length === 0

  return (
    <>
      <h3 className="mb-2">{t('booking.chooseService')}</h3>
      <p className="text-muted mb-6">{t('booking.chooseServiceSub')}</p>

      {loading && showSkeleton && <SkeletonCardGrid />}

      {!loading && services.length === 0 && (
        <EmptyState
          illustration="services"
          title={t('booking.catalogEmpty')}
          description={t('booking.catalogEmpty.desc')}
          action={
            <Button as="link" to="/services">
              {t('services.add')}
            </Button>
          }
        />
      )}

      {!loading && services.length > 0 && (
        <>
          <SearchBox
            value={query}
            onChange={onQueryChange}
            placeholder={t('services.search.placeholder')}
          />

          <div className="services-layout">
            <aside className="services-filters">
              <div className="filter-label">{t('services.filters')}</div>
              {filters.map((f) => (
                <button
                  key={f.value}
                  className={`filter-item ${selectedTag === f.value ? 'active' : ''}`}
                  onClick={() => onTagChange(f.value)}
                >
                  <span>{f.label}</span>
                  <span className="count">{f.count}</span>
                </button>
              ))}
            </aside>

            <div>
              {isEmptySearch ? (
                <EmptyState illustration="search" title={t('services.search.empty')} />
              ) : (
                <div className="services-grid">
                  {visible.map((s) => {
                    const isSelected = String(s.id) === String(selectedServiceId)
                    return (
                      <Card
                        key={s.id}
                        interactive
                        onClick={() => onPickService(s.id)}
                        style={isSelected ? { borderColor: 'var(--accent)' } : undefined}
                      >
                        <div className="flex-between mb-4">
                          <Pill tone={s.tone}>{loc(s.tag, lang)}</Pill>
                          <span className="mono text-muted" style={{ fontSize: 12 }}>
                            {s.duration} {t('services.minutes')}
                          </span>
                        </div>
                        <h3 className="mb-2">{loc(s.name, lang)}</h3>
                        <p className="text-muted line-clamp-3" style={{ fontSize: 13 }}>
                          {loc(s.description, lang)}
                        </p>
                        <div className="flex-between mt-auto" style={{ paddingTop: 'var(--s-6)' }}>
                          <span
                            className="text-accent mono"
                            style={{ fontSize: 16, fontWeight: 600 }}
                          >
                            ${s.price}
                          </span>
                          <Link
                            to={`/services/${s.id}`}
                            onClick={(e) => e.stopPropagation()}
                            className="btn-text"
                            style={{ fontSize: 13 }}
                          >
                            {t('services.details')}
                          </Link>
                        </div>
                      </Card>
                    )
                  })}
                </div>
              )}
            </div>
          </div>
        </>
      )}
    </>
  )
}
