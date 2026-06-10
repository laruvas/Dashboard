import { useEffect, useState } from 'react'
import { useParams, useNavigate } from 'react-router-dom'
import { Button, Pill, Card, Avatar, LabelMono } from '../components/UI'
import { loc } from '../data/mock'
import { getService } from '../data/servicesApi'
import { useT, useSettings } from '../i18n/SettingsContext'
import { Skeleton, useDelayedFlag } from '../components/Skeleton'
import EmptyState from '../components/EmptyState'
import type { Service } from '../types'

export default function ServiceDetail() {
  const t = useT()
  const { lang } = useSettings()
  const { id } = useParams<{ id: string }>()
  const navigate = useNavigate()

  const [service, setService] = useState<Service | null>(null)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  const goBack = () => {
    if (window.history.length > 1) navigate(-1)
    else navigate('/services')
  }

  useEffect(() => {
    if (!id) return
    let mounted = true
    setLoading(true)
    getService(id)
      .then((data) => { if (mounted) { setService(data); setError(null) } })
      .catch(() => { if (mounted) setError(t('services.notFound')) })
      .finally(() => { if (mounted) setLoading(false) })
    return () => { mounted = false }
  }, [id, t])

  const showSkeleton = useDelayedFlag(loading)
  if (loading) {
    if (!showSkeleton) return null
    return (
      <div style={{ maxWidth: 720 }}>
        <Skeleton width={80} height={14} style={{ marginBottom: 16 }} />
        <Skeleton width={70} height={22} radius={999} style={{ marginBottom: 16 }} />
        <Skeleton width="60%" height={32} style={{ marginBottom: 12 }} />
        <Skeleton width="100%" height={14} style={{ marginBottom: 32 }} />
        <Skeleton width="100%" height={100} radius={14} style={{ marginBottom: 24 }} />
        <Skeleton width="30%" height={20} style={{ marginBottom: 16 }} />
        <Skeleton width="100%" height={14} style={{ marginBottom: 8 }} />
        <Skeleton width="90%" height={14} style={{ marginBottom: 8 }} />
        <Skeleton width="80%" height={14} />
      </div>
    )
  }
  if (error || !service) {
    return (
      <>
        <button onClick={goBack} className="btn-text" style={{ fontSize: 13, cursor: 'pointer' }}>
          {t('srv.back')}
        </button>
        <EmptyState
          illustration="services"
          title={error || t('services.notFound')}
        />
      </>
    )
  }

  const includedItems = lang === 'ru' ? [
    'Анкета перед сессией, чтобы сфокусироваться на главном.',
    `${service.duration} минут живого, полного внимания.`,
    'Письменное резюме с действиями в течение 24 часов.',
    'Асинхронные follow-up по email в течение 7 дней.',
  ] : [
    'Pre-call questionnaire to focus on what matters most.',
    `${service.duration} minutes of live, undivided attention.`,
    'Written summary with action items within 24 hours.',
    '7-day async follow-up via email.',
  ]

  return (
    <div style={{ maxWidth: 720 }}>
      <button onClick={goBack} className="btn-text" style={{ fontSize: 13, cursor: 'pointer' }}>
        {t('srv.back')}
      </button>

      <div className="mt-4">
        <Pill tone="accent">{loc(service.tag, lang)}</Pill>
      </div>
      <h1 className="mt-4 mb-2">{loc(service.name, lang)}</h1>
      <p className="subtitle mb-8">{loc(service.description, lang)}</p>

      <Card className="mb-6">
        <div className="grid grid-3" style={{ gap: 'var(--s-6)' }}>
          <div>
            <LabelMono>{t('srv.duration')}</LabelMono>
            <div className="mono" style={{ marginTop: 8 }}>{service.duration} {t('services.minutes')}</div>
          </div>
          <div>
            <LabelMono>{t('srv.price')}</LabelMono>
            <div className="mono text-accent" style={{ fontWeight: 600, marginTop: 8 }}>${service.price}</div>
          </div>
          <div>
            <LabelMono>{t('srv.format')}</LabelMono>
            <div style={{ marginTop: 8 }}>{t('srv.formatOnline')}</div>
          </div>
        </div>
      </Card>

      <h3 className="mb-4">{t('srv.whatsIncluded')}</h3>
      <ul style={{ listStyle: 'none', display: 'flex', flexDirection: 'column', gap: 'var(--s-3)', marginBottom: 'var(--s-8)' }}>
        {includedItems.map((it, i) => (
          <li key={i} className="flex flex-gap-3" style={{ alignItems: 'flex-start' }}>
            <span style={{ width: 6, height: 6, borderRadius: '50%', background: 'var(--accent)', marginTop: 8, flex: 'none' }} />
            <span>{it}</span>
          </li>
        ))}
      </ul>

      <h3 className="mb-4">{t('srv.yourGuide')}</h3>
      <Card className="flex flex-gap-4 mb-8" style={{ alignItems: 'center' }}>
        <Avatar initials="EM" size={48} />
        <div style={{ flex: 1 }}>
          <div style={{ fontWeight: 600 }}>Emily Martinez</div>
          <div className="text-muted" style={{ fontSize: 13 }}>
            {lang === 'ru' ? 'Старший стратег · 8 лет опыта' : 'Senior strategist · 8 years experience'}
          </div>
        </div>
        <div className="text-muted mono" style={{ fontSize: 12 }}>★ 4.9 (124)</div>
      </Card>

      <div className="flex flex-gap-3" style={{ alignItems: 'center' }}>
        <Button size="lg" onClick={() => navigate(`/booking?service=${service.id}`)}>
          {t('srv.bookNow')} · ${service.price}
        </Button>
        <div className="text-subtle" style={{ fontSize: 12 }}>{t('srv.cancellation')}</div>
      </div>
    </div>
  )
}
