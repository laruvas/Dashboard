import { describe, expect, it } from 'vitest'
import { buildPaletteResults, splitResultGroups } from '../src/components/command-palette/commandPaletteUtils.ts'

const t = (key) => key === 'services.minutes' ? 'min' : key

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

const booking = {
  id: 7,
  providerId: 1,
  customerId: 1,
  serviceId: 'svc-1',
  dateISO: '2099-06-16',
  time: '10:00',
  endTime: '11:00',
  durationMin: 60,
  service: 'English lesson',
  total: 100,
  status: 'confirmed',
  withName: 'Anna Smith',
  initials: 'AS',
  customerEmail: 'anna@example.com',
  customerPhone: '+100000000',
  notes: 'Bring workbook',
  createdAt: '2099-01-01',
}

describe('commandPaletteUtils', () => {
  it('returns no results for an empty query', () => {
    const results = buildPaletteResults({
      query: '   ',
      services: [service],
      bookings: [booking],
      lang: 'en',
      t,
    })

    expect(results).toEqual([])
  })

  it('finds services by localized service text', () => {
    const results = buildPaletteResults({
      query: 'speaking',
      services: [service],
      bookings: [],
      lang: 'en',
      t,
    })

    expect(results).toMatchObject([
      {
        id: 'service-svc-1',
        group: 'services',
        title: 'English lesson',
        to: '/services/svc-1',
      },
    ])
  })

  it('finds bookings by customer email and maps to booking detail page', () => {
    const results = buildPaletteResults({
      query: 'anna@example.com',
      services: [],
      bookings: [booking],
      lang: 'en',
      t,
    })

    expect(results).toMatchObject([
      {
        id: 'booking-7',
        group: 'bookings',
        title: 'English lesson — Anna Smith',
        to: '/bookings/7',
      },
    ])
  })

  it('splits mixed results by group', () => {
    const results = buildPaletteResults({
      query: 'english',
      services: [service],
      bookings: [booking],
      lang: 'en',
      t,
    })
    const grouped = splitResultGroups(results)

    expect(grouped.serviceItems).toHaveLength(1)
    expect(grouped.bookingItems).toHaveLength(1)
  })
})
