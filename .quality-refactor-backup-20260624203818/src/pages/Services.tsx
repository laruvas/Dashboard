import { useCallback, useEffect, useMemo, useState } from 'react'
import Modal from '../components/Modal'
import ServiceForm from '../components/ServiceForm'
import { loc } from '../data/mock'
import { listServices, createService, patchService, deleteService } from '../data/servicesApi'
import { useT, useSettings } from '../i18n/SettingsContext'
import { useConfirm } from '../components/Confirm'
import { useToast } from '../components/Toast'
import { useDelayedFlag } from '../components/Skeleton'
import type { Service, ServicePayload } from '../types'
import ServicesHeader from './services/ServicesHeader'
import ServicesSearch from './services/ServicesSearch'
import ServicesGrid from './services/ServicesGrid'
import { EmptyServicesState, ServicesError, ServicesSkeleton } from './services/ServicesState'
import type { EditingState } from './services/servicesTypes'
import { isEditingService } from './services/servicesTypes'
import { buildServiceFilters, filterServices } from './services/servicesUtils'

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

  const load = useCallback((): Promise<void> => {
    setLoading(true)
    return listServices()
      .then((data) => { setServices(data); setError(null) })
      .catch(() => setError(t('services.errorServer')))
      .finally(() => setLoading(false))
  }, [t])

  useEffect(() => { void load() }, [load])

  const filters = useMemo(
    () => buildServiceFilters(services, query, lang, t('services.tab.all')),
    [services, query, lang, t],
  )
  const visible = useMemo(() => filterServices(services, tab, query, lang), [services, tab, query, lang])

  const openCreate = () => setEditing({ __new: true })
  const modalTitle = isEditingService(editing) ? t('services.modal.edit') : t('services.modal.create')
  const isEmptySearch = !loading && !error && services.length > 0 && visible.length === 0
  const showSkeleton = useDelayedFlag(loading)

  const onDelete = async (service: Service) => {
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
      if (isEditingService(editing)) await patchService(editing.id, payload)
      else await createService(payload)
      await load()
      setEditing(null)
      toast.success(t('common.save'))
    } catch (err) {
      toast.error(err instanceof Error ? err.message : 'Failed to save')
    } finally {
      setSaving(false)
    }
  }

  return (
    <>
      <ServicesHeader onCreate={openCreate} />
      <ServicesSearch query={query} onQueryChange={setQuery} />

      {error && <ServicesError error={error} />}
      {!error && loading && showSkeleton && <ServicesSkeleton />}
      {!error && !loading && services.length === 0 && <EmptyServicesState onCreate={openCreate} />}
      {!error && !loading && services.length > 0 && (
        <ServicesGrid
          services={visible}
          filters={filters}
          activeFilter={tab}
          isEmptySearch={isEmptySearch}
          busyId={busyId}
          onFilterChange={setTab}
          onEdit={setEditing}
          onDelete={onDelete}
        />
      )}

      <Modal open={editing !== null} onClose={() => !saving && setEditing(null)} title={modalTitle}>
        {editing !== null && (
          <ServiceForm
            service={isEditingService(editing) ? editing : null}
            onSubmit={handleSubmit}
            onCancel={() => setEditing(null)}
            saving={saving}
          />
        )}
      </Modal>
    </>
  )
}
