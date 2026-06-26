export function makeBooking(overrides = {}) {
  return {
    id: 1,
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
    customerPhone: null,
    notes: null,
    createdAt: '2099-01-01',
    ...overrides,
  }
}

export function makeService(overrides = {}) {
  return {
    id: 'svc-1',
    providerId: 1,
    tag: { en: 'lesson', ru: 'урок' },
    tone: 'accent',
    duration: 60,
    price: 100,
    name: { en: 'English lesson', ru: 'Урок английского' },
    description: { en: 'Speaking practice', ru: 'Разговорная практика' },
    ...overrides,
  }
}

export function makeUser(overrides = {}) {
  return {
    id: 1,
    email: 'anna@example.com',
    name: 'Anna Smith',
    displayName: 'Anna',
    phone: '+1000',
    timezone: 'Europe/London (GMT+1)',
    bio: 'Tutor',
    workingHours: { start: '10:00', end: '16:00' },
    ...overrides,
  }
}
