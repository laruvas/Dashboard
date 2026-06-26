import { loc } from '../../data/mock'
import type { Booking, Lang, Service } from '../../types'
import type { TKey } from '../../i18n/translations'
import type { ResultItem } from './commandPaletteTypes'

type TFn = (key: TKey, params?: Record<string, string | number>) => string

export function isTypingTarget(target: EventTarget | null): boolean {
  if (!(target instanceof HTMLElement)) return false
  return /^(INPUT|TEXTAREA)$/.test(target.tagName)
}

export function isCommandK(e: KeyboardEvent): boolean {
  const isMac = navigator.platform.toUpperCase().includes('MAC')
  const cmd = isMac ? e.metaKey : e.ctrlKey
  return cmd && e.key.toLowerCase() === 'k'
}

export function buildPaletteResults({
  query,
  services,
  bookings,
  lang,
  t,
}: {
  query: string
  services: Service[]
  bookings: Booking[]
  lang: Lang
  t: TFn
}): ResultItem[] {
  if (!query.trim()) return []

  const q = query.toLowerCase()
  const items: ResultItem[] = []

  for (const s of services) {
    const haystack = [
      loc(s.name, lang),
      loc(s.description, lang),
      loc(s.tag, lang),
      s.name?.en,
      s.name?.ru,
      s.tag?.en,
      s.tag?.ru,
    ]
      .filter(Boolean)
      .join(' ')
      .toLowerCase()

    if (haystack.includes(q)) {
      items.push({
        id: `service-${s.id}`,
        group: 'services',
        title: loc(s.name, lang),
        subtitle: `${loc(s.tag, lang)} · ${s.duration} ${t('services.minutes')} · $${s.price}`,
        to: `/services/${s.id}`,
      })
    }
  }

  for (const b of bookings) {
    const haystack = [
      b.service,
      b.withName,
      b.customerEmail,
      b.customerPhone,
      b.notes,
      b.dateISO,
      b.time,
    ]
      .filter(Boolean)
      .join(' ')
      .toLowerCase()

    if (haystack.includes(q)) {
      items.push({
        id: `booking-${b.id}`,
        group: 'bookings',
        title: `${b.service} — ${b.withName || '—'}`,
        subtitle: `${b.dateISO} · ${b.time}${b.endTime ? `–${b.endTime}` : ''} · ${b.customerEmail}`,
        to: `/bookings/${b.id}`,
      })
    }
  }

  return items.slice(0, 20)
}

export function splitResultGroups(results: ResultItem[]): {
  serviceItems: ResultItem[]
  bookingItems: ResultItem[]
} {
  return {
    serviceItems: results.filter((r) => r.group === 'services'),
    bookingItems: results.filter((r) => r.group === 'bookings'),
  }
}
