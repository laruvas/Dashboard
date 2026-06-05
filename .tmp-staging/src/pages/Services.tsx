import { useEffect, useMemo, useState, type MouseEvent } from 'react'
import { Button, Card, Pill } from '../components/UI'
import Modal from '../components/Modal'
import ServiceForm from '../components/ServiceForm'
import { IconSearch } from '../components/Icons'
import { loc } from '../data/mock'
import { listServices, createService, patchService, deleteService } from '../data/servicesApi'
import { useT, useSettings } from '../i18n/SettingsContext'
import { useConfirm } from '../components/Confirm'
import { useToast } from '../components/Toast'
import EmptyState from '../components/EmptyState'
import { SkeletonCardGrid, useDelayedFlag } from '../components/Skeleton'
import type { Service, ServicePayload, Lang } from '../types'

function matchesQuery(service: Service, q: string, lang: Lang): boolean {
  if (!q) return true
  const haystack = [
    loc(service.name, lang),
    loc(service.description, lang),
    loc(service.tag, lang),
    service.name?.en, service.name?.ru,
    service.description?.en, service.description?.ru,
    service.tag?.en, service.tag?.ru,
  ].filter(Boolean).join(' ').toLowerCase()
  return haystack.includes(q.toLowerCase())
}

// editing state: null = closed, {} sentinel = create, Service = edit
type EditingState = Service | { __new: true } | null
const isEditing = (e: EditingState): e is Service => e !== null && !('__new' in e)

export default function Services() {
  const t = useT()
  const { lang } = useSettings()
  const confirm = useConfirm()
  const toast = useToast()
  const [services, setServices] = useState<Service[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)
  const [tab, setTab] = useState<string>('all')
  const [query, setQuery] = useState('')

  const [editing, setEditing] = useState<EditingState>(null)
  const [saving, setSaving] = useState(false)
  const [busyId, setBusyId] = useState<string | null>(null)

  const load = (): Promise<void> => {
    setLoading(true)
    return listServices()
      .then((data) => { setServices(data); setError(null) })
      .catch(() => setError(t('services.errorServer')))
      .finally(() => setLoading(false))
  }

  useEffect(() => { void load() }, [])  // eslint-disable-line react-hooks/exhaustive-deps

  const filters = useMemo(() => {
    const matchedAll = services.filter(s => matchesQuery(s, query, lang))
    const seen = new Map<string, Service['tag']>()
    for (const s of services) {
      const key = s.tag?.en
      if (key && !seen.has(key)) seen.set(key, s.tag)
    }
    return [
      { value: 'all', label: t('services.tab.all'), count: matchedAll.length },
      ...[...seen.entries()].map(([key, tag]) => ({
        value: key,
        label: loc(tag, lang),
        count: matchedAll.filter(s => s.tag?.en === key).length,
      })),
    ]
  }, [services, query, lang, t])

  const visible = useMemo(() => {
    let list = services
    if (tab !== 'all') list = list.filter(s => s.tag?.en === tab)
    if (query) list = list.filter(s => matchesQuery(s, query, lang))
    return list
  }, [services, tab, query, lang])

  const openCreate = () => setEditing({ __new: true })

  const openEdit = (e: MouseEvent<HTMLButtonElement>, service: Service) => {
    e.preventDefault(); e.stopPropagation()
    setEditing(service)
  }

  const onDelete = async (e: MouseEvent<HTMLButtonElement>, service: Service) => {
    e.preventDefault(); e.stopPropagation()
    const ok = await confirm({
      title: t('services.action.delete'),
      message: t('services.deleteConfirm', { name: loc(service.name, lang) }),
      confirmText: t('services.action.delete'),
      danger: true,
    })
    if (!ok) return
    try {
      setBusyId(service.id)
      await deleteService(service.id)
      setServices(prev => prev.filter(s => s.id !== service.id))
      toast.success(t('services.action.delete'))
    } catch (err) {
      toast.error(err instanceof Error ? err.message : 'Failed to delete')
    } finally {
      setBusyId(null)
    }
  }

  const handleSubmit = async (payload: ServicePayload) => {
    try {
      setSaving(true)
      if (isEditing(editing)) await patchService(editing.id, payload)
      else                    await createService(payload)
      await load()
      setEditing(null)
      toast.success(t('common.save'))
    } catch (err) {
      toast.error(err instanceof Error ? err.message : 'Failed to save')
    } finally {
      setSaving(false)
    }
  }

  const modalTitle = isEditing(editing) ? t('services.modal.edit') : t('services.modal.create')
  const isEmptySearch = !loading && !error && services.length > 0 && visible.length === 0
  const showSkeleton = useDelayedFlag(loading)

  return (
    <>
      <div className="flex-between mb-6">
        <div>
          <h1>{t('services.title')}</h1>
          <p className="subtitle mt-2">{t('services.subtitle')}</p>
        </div>
        <Button variant="ghost" onClick={openCreate}>{t('services.add')}</Button>
      </div>

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
          onChange={(e) => setQuery(e.target.value)}
          placeholder={t('services.search.placeholder')}
          style={{
            flex: 1, border: 'none', outline: 'none', background: 'none',
            color: 'var(--text)', fontSize: 13,
          }}
        />
      </div>

      {error && (
        <div className="card" style={{ borderColor: 'rgba(248,113,113,0.32)', color: 'var(--danger)' }}>
          {error}
        </div>
      )}

      {!error && loading && showSkeleton && <SkeletonCardGrid />}

      {!error && !loading && services.length === 0 && (
        <EmptyState
          illustration="services"
          title={t('services.empty')}
          action={<Button onClick={openCreate}>{t('services.add')}</Button>}
        />
      )}

      {!error && !loading && services.length > 0 && (
        <div className="services-layout">
          <aside className="services-filters">
            <div className="filter-label">{t('services.filters')}</div>
            {filters.map(f => (
              <button
                key={f.value}
                className={`filter-item ${tab === f.value ? 'active' : ''}`}
                onClick={() => setTab(f.value)}
              >
                <span>{f.label}</span>
                <span className="count">{f.count}</span>
              </button>
            ))}
          </aside>

          <div>
            {isEmptySearch ? (
              <EmptyState
                illustration="search"
                title={t('services.search.empty')}
              />
            ) : (
              <div className="services-grid">
                {visible.map((s) => (
                  <Card
                    key={s.id}
                    as="link"
                    to={`/services/${s.id}`}
                    interactive
                    style={{
                      position: 'relative',
                      ...(s.tone === 'accent' ? { borderColor: 'var(--accent-ring)' } : null),
                    }}
                  >
                    <div className="service-actions">
                      <button
                        type="button"
                        onClick={(e) => openEdit(e, s)}
                        className="btn-text"
                        style={{ fontSize: 12, padding: '2px 6px' }}
                      >
                        {t('services.action.edit')}
                      </button>
                      <button
                        type="button"
                        onClick={(e) => onDelete(e, s)}
                        disabled={busyId === s.id}
                        className="btn-text"
                        style={{ fontSize: 12, padding: '2px 6px', color: 'var(--danger)' }}
                      >
                        {busyId === s.id ? t('bookings.deleting') : t('services.action.delete')}
                      </button>
                    </div>

                    <div className="flex-between mb-4">
                      <Pill tone={s.tone}>{loc(s.tag, lang)}</Pill>
                      <span className="mono text-muted" style={{ fontSize: 12 }}>{s.duration} {t('services.minutes')}</span>
                    </div>
                    <h3 className="mb-2" style={{ paddingRight: 80 }}>{loc(s.name, lang)}</h3>
                    <p className="text-muted line-clamp-3" style={{ fontSize: 13 }}>{loc(s.description, lang)}</p>
                    <div className="text-accent mono mt-auto" style={{ fontSize: 16, fontWeight: 600, paddingTop: 'var(--s-6)' }}>${s.price}</div>
                  </Card>
                ))}
              </div>
            )}
          </div>
        </div>
      )}

      <Modal open={editing !== null} onClose={() => !saving && setEditing(null)} title={modalTitle}>
        {editing !== null && (
          <ServiceForm
            service={isEditing(editing) ? editing : null}
            onSubmit={handleSubmit}
            onCancel={() => setEditing(null)}
            saving={saving}
          />
        )}
      </Modal>
    </>
  )
}
