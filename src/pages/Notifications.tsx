import { useEffect, useMemo, useState, type ComponentType, type SVGProps } from 'react'
import { useNavigate } from 'react-router-dom'
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
import {
  deleteNotification,
  listNotifications,
  markAllRead,
  notifyNotificationsChanged,
  patchNotification,
} from '../data/notificationsApi'
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

type NotifTab = 'all' | 'unread' | 'created' | 'cancelled' | 'rescheduled'

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

function formatDate(iso: string | undefined, lang: Lang): string {
  if (!iso) return ''
  const [year, month, day] = iso.split('-').map(Number)
  if (!year || !month || !day) return iso
  return new Date(year, month - 1, day).toLocaleDateString(lang === 'ru' ? 'ru-RU' : 'en-US', {
    month: 'short',
    day: 'numeric',
    year: 'numeric',
  })
}

function formatSchedule(dateISO: string | undefined, time: string | undefined, lang: Lang): string {
  const date = formatDate(dateISO, lang)
  if (!date && !time) return ''
  if (!date) return time || ''
  if (!time) return date
  return `${date}, ${time}`
}

/** Map a notification kind to localised title/text using its params. */
function renderNotif(
  n: AppNotification,
  t: ReturnType<typeof useT>,
  lang: Lang,
): { title: string; text: string } {
  const p = n.params || {}
  switch (n.kind) {
    case 'calendar':
      return {
        title: t('notif.kind.created.title'),
        text: t('notif.kind.created.text', {
          service: p.service || '—',
          withName: p.withName || '—',
          dateISO: formatDate(p.dateISO, lang),
          time: p.time || '',
        }),
      }
    case 'close':
      return {
        title: t('notif.kind.cancelled.title'),
        text: t('notif.kind.cancelled.text', {
          service: p.service || '—',
          dateISO: formatDate(p.dateISO, lang),
          time: p.time || '',
        }),
      }
    case 'clock':
      return {
        title: t('notif.kind.rescheduled.title'),
        text: t('notif.kind.rescheduled.text', {
          service: p.service || '—',
          oldDateISO: formatSchedule(p.oldDateISO || p.dateISO, p.oldTime, lang),
          oldTime: '',
          newDateISO: formatSchedule(p.newDateISO || p.dateISO, p.newTime || p.time, lang),
          newTime: '',
        }),
      }
    default:
      return { title: t('notif.kind.generic.title'), text: '' }
  }
}

function matchesTab(notification: AppNotification, tab: NotifTab): boolean {
  if (tab === 'all') return true
  if (tab === 'unread') return Boolean(notification.unread)
  if (tab === 'created') return notification.kind === 'calendar'
  if (tab === 'cancelled') return notification.kind === 'close'
  if (tab === 'rescheduled') return notification.kind === 'clock'
  return true
}

export default function Notifications() {
  const navigate = useNavigate()
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
        notifyNotificationsChanged()
      })
      .catch(() => setError(t('notif.errorServer')))
      .finally(() => setLoading(false))
  }
  useEffect(() => {
    load()
  }, []) // eslint-disable-line react-hooks/exhaustive-deps

  const unreadCount = useMemo(() => items.filter((i) => i.unread).length, [items])
  const visible = useMemo(() => items.filter((item) => matchesTab(item, tab)), [items, tab])
  const emitUnreadCount = (nextItems: AppNotification[]) => {
    notifyNotificationsChanged({ unreadCount: nextItems.filter((item) => item.unread).length })
  }

  const markAll = async () => {
    const nextItems = items.map((item) => ({ ...item, unread: false }))
    setItems(nextItems)
    emitUnreadCount(nextItems)
    try {
      await markAllRead()
    } catch {
      /* optimistic, ignore */
    }
  }

  const markOne = async (id: number, currentlyUnread: boolean | undefined) => {
    if (!currentlyUnread) return
    const nextItems = items.map((item) => (item.id === id ? { ...item, unread: false } : item))
    setItems(nextItems)
    emitUnreadCount(nextItems)
    try {
      await patchNotification(id, { unread: false })
    } catch {
      /* ignore */
    }
  }

  const deleteOne = async (id: number) => {
    const prevItems = items
    const nextItems = items.filter((item) => item.id !== id)
    setItems(nextItems)
    emitUnreadCount(nextItems)
    try {
      await deleteNotification(id)
    } catch {
      setItems(prevItems)
      emitUnreadCount(prevItems)
    }
  }

  const openNotification = async (notification: AppNotification) => {
    await markOne(notification.id, notification.unread)
    const bookingId = notification.params?.bookingId
    if (bookingId != null) navigate(`/bookings/${bookingId}`)
  }

  const TABS: TabItem<NotifTab>[] = [
    { value: 'all', label: t('notif.tab.all'), count: loading ? undefined : items.length },
    { value: 'unread', label: t('notif.tab.unread'), count: loading ? undefined : unreadCount },
    {
      value: 'created',
      label: t('notif.tab.created'),
      count: loading ? undefined : items.filter((i) => i.kind === 'calendar').length,
    },
    {
      value: 'cancelled',
      label: t('notif.tab.cancelled'),
      count: loading ? undefined : items.filter((i) => i.kind === 'close').length,
    },
    {
      value: 'rescheduled',
      label: t('notif.tab.rescheduled'),
      count: loading ? undefined : items.filter((i) => i.kind === 'clock').length,
    },
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
            const { title, text } = renderNotif(n, t, lang)
            const canOpen = n.params?.bookingId != null

            return (
              <div
                className={`notif-row ${canOpen ? 'clickable' : ''}`}
                key={n.id}
                role={canOpen ? 'button' : undefined}
                tabIndex={canOpen ? 0 : undefined}
                onClick={() => {
                  if (canOpen) void openNotification(n)
                  else void markOne(n.id, n.unread)
                }}
                onKeyDown={(e) => {
                  if (!canOpen) return
                  if (e.key === 'Enter' || e.key === ' ') {
                    e.preventDefault()
                    void openNotification(n)
                  }
                }}
              >
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
                <div className="notif-time" style={{ textAlign: 'right' }}>
                  <div>{relativeTime(n.createdAt, lang)}</div>
                  <div className="notif-actions">
                    {canOpen && (
                      <button
                        type="button"
                        className="notif-action"
                        onClick={(e) => {
                          e.stopPropagation()
                          void openNotification(n)
                        }}
                      >
                        {t('notif.open')} →
                      </button>
                    )}
                    {n.unread && (
                      <button
                        type="button"
                        className="notif-action muted"
                        onClick={(e) => {
                          e.stopPropagation()
                          void markOne(n.id, n.unread)
                        }}
                      >
                        {t('notif.markRead')}
                      </button>
                    )}
                    <button
                      type="button"
                      className="notif-action danger"
                      onClick={(e) => {
                        e.stopPropagation()
                        void deleteOne(n.id)
                      }}
                    >
                      {t('notif.delete')}
                    </button>
                  </div>
                </div>
              </div>
            )
          })}
        </div>
      )}
    </>
  )
}

