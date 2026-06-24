import { describe, expect, it } from 'vitest'
import { buildServiceFilters, filterServices, matchesServiceQuery } from '../src/pages/services/servicesUtils.ts'
import {
  toServiceFormValues,
  toServicePayload,
  validateServiceForm,
} from '../src/components/service-form/serviceFormUtils.ts'

const t = (key) => key

const service = {
  id: 'svc-1',
  providerId: 1,
  tag: { en: 'lesson', ru: 'урок' },
  tone: 'accent',
  duration: 60,
  price: 100,
  name: { en: 'English lesson', ru: 'Урок английского' },
  description: { en: 'Speaking practice', ru: 'Разговорная практика' },
}

const secondService = {
  ...service,
  id: 'svc-2',
  tag: { en: 'consulting', ru: 'консультация' },
  name: { en: 'Career consulting', ru: 'Карьерная консультация' },
  description: { en: 'Career plan', ru: 'План карьеры' },
}

describe('servicesUtils', () => {
  it('matches service by localized text', () => {
    expect(matchesServiceQuery(service, 'speaking', 'en')).toBe(true)
    expect(matchesServiceQuery(service, 'карьеры', 'ru')).toBe(false)
  })

  it('builds filters with counts respecting query', () => {
    const filters = buildServiceFilters([service, secondService], 'career', 'en', 'All')

    expect(filters).toEqual([
      { value: 'all', label: 'All', count: 1 },
      { value: 'lesson', label: 'lesson', count: 0 },
      { value: 'consulting', label: 'consulting', count: 1 },
    ])
  })

  it('filters services by tag and query', () => {
    expect(filterServices([service, secondService], 'consulting', '', 'en').map(s => s.id)).toEqual(['svc-2'])
    expect(filterServices([service, secondService], 'all', 'english', 'en').map(s => s.id)).toEqual(['svc-1'])
  })
})

describe('serviceFormUtils', () => {
  it('maps service to form values', () => {
    expect(toServiceFormValues(service)).toMatchObject({
      tagEn: 'lesson',
      tagRu: 'урок',
      tone: 'accent',
      duration: 60,
      price: 100,
      nameEn: 'English lesson',
      nameRu: 'Урок английского',
      descEn: 'Speaking practice',
      descRu: 'Разговорная практика',
    })
  })

  it('maps form values to trimmed payload', () => {
    const payload = toServicePayload({
      tagEn: ' lesson ',
      tagRu: ' урок ',
      tone: 'muted',
      duration: '45',
      price: '120',
      nameEn: ' Name ',
      nameRu: ' Имя ',
      descEn: ' Desc ',
      descRu: ' Описание ',
    })

    expect(payload).toEqual({
      tag: { en: 'lesson', ru: 'урок' },
      tone: 'muted',
      duration: 45,
      price: 120,
      name: { en: 'Name', ru: 'Имя' },
      description: { en: 'Desc', ru: 'Описание' },
    })
  })

  it('validates required fields and numeric constraints', () => {
    const errors = validateServiceForm({
      tagEn: '', tagRu: '', tone: 'muted', duration: 0, price: -1,
      nameEn: '', nameRu: '', descEn: '', descRu: '',
    }, t)

    expect(errors).toMatchObject({
      tagEn: 'validation.required',
      duration: 'validation.positiveNumber',
      price: 'validation.nonNegativeNumber',
    })
  })
})
