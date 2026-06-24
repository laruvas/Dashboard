import type { MouseEvent } from 'react'
import { Card, Pill } from '../../components/UI'
import EmptyState from '../../components/EmptyState'
import { loc } from '../../data/mock'
import { useT, useSettings } from '../../i18n/SettingsContext'
import type { Service } from '../../types'
import type { ServiceFilterItem } from './servicesTypes'

interface ServicesGridProps {
  services: Service[]
  filters: ServiceFilterItem[]
  activeFilter: string
  isEmptySearch: boolean
  busyId: string | null
  onFilterChange: (value: string) => void
  onEdit: (service: Service) => void
  onDelete: (service: Service) => void
}

export default function ServicesGrid({
  services,
  filters,
  activeFilter,
  isEmptySearch,
  busyId,
  onFilterChange,
  onEdit,
  onDelete,
}: ServicesGridProps) {
  const t = useT()
  const { lang } = useSettings()

  return (
    <div className="services-layout">
      <aside className="services-filters">
        <div className="filter-label">{t('services.filters')}</div>
        {filters.map(f => (
          <button
            key={f.value}
            className={`filter-item ${activeFilter === f.value ? 'active' : ''}`}
            onClick={() => onFilterChange(f.value)}
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
            {services.map((service) => (
              <ServiceCard
                key={service.id}
                service={service}
                busy={busyId === service.id}
                onEdit={onEdit}
                onDelete={onDelete}
              />
            ))}
          </div>
        )}
      </div>
    </div>
  )
}

function ServiceCard({
  service,
  busy,
  onEdit,
  onDelete,
}: {
  service: Service
  busy: boolean
  onEdit: (service: Service) => void
  onDelete: (service: Service) => void
}) {
  const t = useT()
  const { lang } = useSettings()

  const stopAndRun = (e: MouseEvent<HTMLButtonElement>, action: () => void) => {
    e.preventDefault()
    e.stopPropagation()
    action()
  }

  return (
    <Card
      as="link"
      to={`/services/${service.id}`}
      interactive
      style={{
        position: 'relative',
        ...(service.tone === 'accent' ? { borderColor: 'var(--accent-ring)' } : null),
      }}
    >
      <div className="service-actions">
        <button
          type="button"
          onClick={(e) => stopAndRun(e, () => onEdit(service))}
          className="btn-text"
          style={{ fontSize: 12, padding: '2px 6px' }}
        >
          {t('services.action.edit')}
        </button>
        <button
          type="button"
          onClick={(e) => stopAndRun(e, () => onDelete(service))}
          disabled={busy}
          className="btn-text"
          style={{ fontSize: 12, padding: '2px 6px', color: 'var(--danger)' }}
        >
          {busy ? t('bookings.deleting') : t('services.action.delete')}
        </button>
      </div>

      <div className="flex-between mb-4">
        <Pill tone={service.tone}>{loc(service.tag, lang)}</Pill>
        <span className="mono text-muted" style={{ fontSize: 12 }}>{service.duration} {t('services.minutes')}</span>
      </div>
      <h3 className="mb-2" style={{ paddingRight: 80 }}>{loc(service.name, lang)}</h3>
      <p className="text-muted line-clamp-3" style={{ fontSize: 13 }}>{loc(service.description, lang)}</p>
      <div className="text-accent mono mt-auto" style={{ fontSize: 16, fontWeight: 600, paddingTop: 'var(--s-6)' }}>${service.price}</div>
    </Card>
  )
}
