import { makeBooking, makeService } from './helpers/factories.mjs'
import { describe, expect, it } from 'vitest'
import {
  buildPaletteResults,
  splitResultGroups,
} from '../src/components/command-palette/commandPaletteUtils.ts'

const t = (key) => (key === 'services.minutes' ? 'min' : key)

const service = makeService()
const booking = makeBooking({ id: 7 })

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
