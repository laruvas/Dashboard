import { useEffect, useMemo, useState, type ComponentType, type SVGProps } from 'react'
import { Button, Tabs, type TabItem } from '../components/UI'
import {
  IconCheck,
  IconCalendar,
  IconUser,
  IconDollar,
  IconStar,
  IconClose,
  IconClock,
} from '../components/Icons'
import { listNotifications, patchNotification, markAllRead } from '../data/notificationsApi'
import { useT, useSettings } from '../i18n/SettingsContext'
import EmptyState from '../components/EmptyState'
import { SkeletonTableRow, useDelayedFlag } from '../components/Skeleton'
import type { AppNotification, NotificationKind, Lang } from '../types'

const ICONS: Record<NotificationKind, ComponentType<SVGProps<SVGSVGElement>>> = {
  check: IconCheck,
  calendar: IconCalendar,
  user: IconUser,
  dollar: IconDollar,
  star: IconStar,
  close: IconClose,
  clock: IconClock,
}

type NotifTab = 'all' | 'unread'

/** "5 минут назад" / "5 min ago" — coarse, good enough for a feed. */
function relativeTime(iso: string, lang: Lang): string {
  const then = new Date(iso).getTime()
  if (!Number.isFinite(then)) return ''
  const seconds = Math.floor((Date.now() - then) / 1000)
  const ru = lang === 'ru'
  if (seconds < 60) return ru ? 'только что' : 'just now'
  if (seconds < 3600)
    return ru ? `${Math.floor(seconds / 60)} мин назад` : `${Math.floor(seconds / 60)} min ago`
  if (seconds < 86400)
    return ru ? `${Math.floor(seconds / 3600)} ч назад` : `${Math.floor(seconds / 3600)} h ago`
  if (seconds < 604800)
    return ru ? `${Math.floor(seconds / 86400)} дн назад` : `${Math.floor(seconds / 86400)} d ago`
  return new Date(iso).toLocaleDateString(ru ? 'ru-RU' : 'en-US')
}

/** Map a notification kind to localised title/text using its params. */
function renderNotif(
  n: AppNotification,
  t: ReturnType<typeof useT>,
): { title: string; text: string } {
  const p = n.params || {}
  switch (n.kind) {
    case 'calendar':
      return {
        title: t('notif.kind.created.title'),
        text: t('notif.kind.created.text', {
          service: p.service || '—',
          withName: p.withName || '—',
          dateISO: p.dateISO || '',
          time: p.time || '',
        }),
      }
    case 'close':
      return {
        title: t('notif.kind.cancelled.title'),
        text: t('notif.kind.cancelled.text', {
          service: p.service || '—',
          dateISO: p.dateISO || '',
          time: p.time || '',
        }),
      }
    case 'clock':
      return {
        title: t('notif.kind.rescheduled.title'),
        text: t('notif.kind.rescheduled.text', {
          service: p.service || '—',
          dateISO: p.dateISO || '',
          time: p.time || '',
        }),
      }
    default:
      return { title: t('notif.kind.generic.title'), text: '' }
  }
}

export default function Notifications() {
  const t = useT()
  const { lang } = useSettings()
  const [items, setItems] = useState<AppNotification[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)
  const [tab, setTab] = useState<NotifTab>('all')
  const showSkeleton = useDelayedFlag(loading)

  const load = () => {
    setLoading(true)
    listNotifications()
      .then((rows) => {
        setItems(rows)
        setError(null)
      })
      .catch(() => setError(t('notif.errorServer')))
      .finally(() => setLoading(false))
  }
  useEffect(() => {
    load()
  }, []) // eslint-disable-line react-hooks/exhaustive-deps

  const unreadCount = useMemo(() => items.filter((i) => i.unread).length, [items])
  const visible = tab === 'unread' ? items.filter((i) => i.unread) : items

  const markAll = async () => {
    setItems((prev) => prev.map((i) => ({ ...i, unread: false })))
    try {
      await markAllRead()
    } catch {
      /* optimistic, ignore */
    }
  }
  const markOne = async (id: number, currentlyUnread: boolean | undefined) => {
    if (!currentlyUnread) return
    setItems((prev) => prev.map((i) => (i.id === id ? { ...i, unread: false } : i)))
    try {
      await patchNotification(id, { unread: false })
    } catch {
      /* ignore */
    }
  }

  const TABS: TabItem<NotifTab>[] = [
    { value: 'all', label: t('notif.tab.all'), count: loading ? undefined : items.length },
    { value: 'unread', label: t('notif.tab.unread'), count: loading ? undefined : unreadCount },
  ]

  return (
    <>
      <div className="flex-between mb-6">
        <div>
          <h1>{t('notif.title')}</h1>
          <p className="subtitle mt-2">{t('notif.subtitle')}</p>
        </div>
        <Button variant="ghost" size="sm" onClick={markAll} disabled={unreadCount === 0}>
          {t('notif.markAllRead')}
        </Button>
      </div>

      <Tabs items={TABS} value={tab} onChange={setTab} />

      {error && (
        <div
          className="card"
          style={{ borderColor: 'rgba(248,113,113,0.32)', color: 'var(--danger)' }}
        >
          {error}
        </div>
      )}

      {!error && loading && showSkeleton && (
        <div className="notif-list">
          {Array.from({ length: 4 }, (_, i) => (
            <SkeletonTableRow key={i} cols={3} />
          ))}
        </div>
      )}

      {!error && !loading && visible.length === 0 && (
        <EmptyState illustration="bell" title={t('notif.empty')} />
      )}

      {!error && !loading && visible.length > 0 && (
        <div className="notif-list">
          {visible.map((n) => {
            const Icon = ICONS[n.kind] || IconCheck
            const { title, text } = renderNotif(n, t)
            return (
              <div className="notif-row" key={n.id} onClick={() => markOne(n.id, n.unread)}>
                <div className={`notif-dot ${!n.unread ? 'read' : ''}`} />
                <div className={`notif-icon ${n.tone === 'accent' ? 'accent' : ''}`}>
                  <Icon />
                </div>
                <div className="notif-content">
                  <div style={{ fontWeight: 600 }}>{title}</div>
                  <div className="text-muted" style={{ fontSize: 13 }}>
                    {text}
                  </div>
                </div>
                <div className="notif-time">{relativeTime(n.createdAt, lang)}</div>
              </div>
            )
          })}
        </div>
      )}
    </>
  )
}
