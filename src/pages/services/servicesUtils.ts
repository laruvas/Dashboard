import { loc } from '../../data/mock'
import type { Lang, Service } from '../../types'
import type { ServiceFilterItem } from './servicesTypes'

export function matchesServiceQuery(service: Service, query: string, lang: Lang): boolean {
  if (!query) return true
  const haystack = [
    loc(service.name, lang),
    loc(service.description, lang),
    loc(service.tag, lang),
    service.name?.en, service.name?.ru,
    service.description?.en, service.description?.ru,
    service.tag?.en, service.tag?.ru,
  ].filter(Boolean).join(' ').toLowerCase()
  return haystack.includes(query.toLowerCase())
}

export function buildServiceFilters(
  services: Service[],
  query: string,
  lang: Lang,
  allLabel: string,
): ServiceFilterItem[] {
  const matchedAll = services.filter(s => matchesServiceQuery(s, query, lang))
  const seen = new Map<string, Service['tag']>()

  for (const s of services) {
    const key = s.tag?.en
    if (key && !seen.has(key)) seen.set(key, s.tag)
  }

  return [
    { value: 'all', label: allLabel, count: matchedAll.length },
    ...[...seen.entries()].map(([key, tag]) => ({
      value: key,
      label: loc(tag, lang),
      count: matchedAll.filter(s => s.tag?.en === key).length,
    })),
  ]
}

export function filterServices(
  services: Service[],
  activeTag: string,
  query: string,
  lang: Lang,
): Service[] {
  let list = services
  if (activeTag !== 'all') list = list.filter(s => s.tag?.en === activeTag)
  if (query) list = list.filter(s => matchesServiceQuery(s, query, lang))
  return list
}
