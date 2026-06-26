// Integration tests for scripts/server.mjs.
//
// Boots the Express app against an in-memory libSQL database and exercises
// the most security-relevant user flows:
//   - healthcheck
//   - register/login round-trip
//   - refresh-token rotation (the bug called out in REPORT.md)
//   - availability calculation with real bookings
//   - service validation
//
// IMPORTANT: env vars must be set BEFORE the first import of server.mjs,
// otherwise db.mjs picks up the dev path and caches it.

process.env.LIBSQL_URL = 'file::memory:'
process.env.JWT_SECRET = 'integration-test-secret'
process.env.PORT = '0'

import { describe, it, expect, beforeEach } from 'vitest'

const { app, validateServicePayload } = await import('../scripts/server.mjs')
const { dbRun } = await import('../scripts/db.mjs')
const request = (await import('supertest')).default

async function resetDb() {
  await dbRun('DELETE FROM bookings')
  await dbRun('DELETE FROM notifications')
  await dbRun('DELETE FROM refresh_tokens')
  await dbRun('DELETE FROM services')
  await dbRun('DELETE FROM users')
}

let counter = 0
async function registerUser(overrides = {}) {
  counter += 1
  const email = overrides.email || `u${counter}-${Date.now()}@test.co`
  const payload = { email, password: 'password123', name: `User ${counter}`, ...overrides }
  const res = await request(app).post('/register').send(payload)
  return { res, email, ...res.body }
}

describe('GET /healthz', () => {
  it('returns 200 without touching the DB', async () => {
    const res = await request(app).get('/healthz')
    expect(res.status).toBe(200)
    expect(res.body).toEqual({ ok: true })
  })
})

describe('POST /register', () => {
  beforeEach(resetDb)

  it('creates a user and returns a token pair', async () => {
    const { res, user } = await registerUser({ email: 'new@x.co' })
    expect(res.status).toBe(201)
    expect(typeof res.body.accessToken).toBe('string')
    expect(typeof res.body.refreshToken).toBe('string')
    expect(user.email).toBe('new@x.co')
  })

  it('rejects a short password', async () => {
    const res = await request(app).post('/register').send({
      email: 'short@x.co',
      password: '123',
      name: 'X',
    })
    expect(res.status).toBe(400)
    expect(res.body.error).toMatch(/6 characters/)
  })

  it('rejects a duplicate email', async () => {
    await registerUser({ email: 'dup@x.co' })
    const res = await request(app).post('/register').send({
      email: 'dup@x.co',
      password: 'password123',
      name: 'Y',
    })
    expect(res.status).toBe(400)
    expect(res.body.error).toMatch(/exists/)
  })

  it('rejects an invalid email format', async () => {
    const res = await request(app).post('/register').send({
      email: 'not-an-email',
      password: 'password123',
      name: 'Z',
    })
    expect(res.status).toBe(400)
  })
})

describe('POST /login', () => {
  beforeEach(resetDb)

  it('issues a token pair for valid credentials', async () => {
    await registerUser({ email: 'login@x.co', password: 'password123' })
    const res = await request(app).post('/login').send({
      email: 'login@x.co',
      password: 'password123',
    })
    expect(res.status).toBe(200)
    expect(typeof res.body.accessToken).toBe('string')
  })

  it('returns 400 on wrong password (not 401, intentionally vague)', async () => {
    await registerUser({ email: 'wrong@x.co', password: 'password123' })
    const res = await request(app).post('/login').send({
      email: 'wrong@x.co',
      password: 'wrong-password',
    })
    expect(res.status).toBe(400)
    expect(res.body.error).toMatch(/incorrect/i)
  })
})

describe('Refresh token rotation', () => {
  beforeEach(resetDb)

  it('returns a new pair and invalidates the old refresh token', async () => {
    const { refreshToken } = await registerUser({
      email: 'rot@x.co',
    })

    const refreshRes = await request(app).post('/refresh').send({ refreshToken })
    expect(refreshRes.status).toBe(200)
    // refresh tokens rotate; access tokens may legitimately match if signed in the same second
    // (JWT has second-precision iat and is deterministic given identical payload + iat).
    expect(refreshToken).not.toBe(refreshRes.body.refreshToken)
    expect(typeof refreshRes.body.accessToken).toBe('string')

    const second = await request(app).post('/refresh').send({ refreshToken })
    expect(second.status).toBe(401)
  })

  it('rejects an unknown refresh token', async () => {
    const res = await request(app).post('/refresh').send({
      refreshToken: 'definitely-not-a-real-token',
    })
    expect(res.status).toBe(401)
  })
})

describe('Auth middleware', () => {
  beforeEach(resetDb)

  it('rejects /users/:id without a bearer token', async () => {
    const { user } = await registerUser()
    const res = await request(app).get(`/users/${user.id}`)
    expect(res.status).toBe(401)
  })

  it("rejects /users/:id for someone else's id", async () => {
    const me = await registerUser()
    const { user: otherUser } = await registerUser({ email: 'other@x.co' })
    const res = await request(app)
      .get(`/users/${otherUser.id}`)
      .set('Authorization', `Bearer ${me.accessToken}`)
    expect(res.status).toBe(403)
  })
})

describe('validateServicePayload (unit, exported from server.mjs)', () => {
  it('returns [] for a valid payload', () => {
    expect(
      validateServicePayload({
        tag: { en: 't' },
        name: { en: 'n' },
        description: { en: 'd' },
        duration: 60,
        price: 1000,
      }),
    ).toEqual([])
  })

  it('collects multiple errors at once', () => {
    const errs = validateServicePayload({ tag: 'not-an-object' })
    expect(errs.length).toBeGreaterThanOrEqual(4)
  })

  it('flags non-positive duration', () => {
    const errs = validateServicePayload({
      tag: { en: 't' },
      name: { en: 'n' },
      description: { en: 'd' },
      duration: -5,
      price: 0,
    })
    expect(errs).toContain('duration must be > 0')
  })
})

describe('POST /services + GET /availability (full flow)', () => {
  beforeEach(resetDb)

  it('creates a service and returns its id', async () => {
    const { accessToken } = await registerUser({ email: 'svc@x.co' })
    const res = await request(app)
      .post('/services')
      .set('Authorization', `Bearer ${accessToken}`)
      .send({
        tag: { en: 'lesson' },
        name: { en: 'English lesson' },
        description: { en: '1-on-1 tutoring' },
        duration: 60,
        price: 2000,
      })
    expect(res.status).toBe(201)
    expect(res.body.id).toBeGreaterThan(0)
    expect(res.body.providerId).toBeGreaterThan(0)
  })

  it('returns slots for a future weekday with no bookings', async () => {
    const { accessToken, user } = await registerUser({ email: 'av@x.co' })
    await request(app)
      .post('/services')
      .set('Authorization', `Bearer ${accessToken}`)
      .send({
        tag: { en: 'lesson' },
        name: { en: 'n' },
        description: { en: 'd' },
        duration: 60,
        price: 0,
      })
    const res = await request(app)
      .get(`/availability/${user.id}?date=2099-06-16&duration=60`)
      .set('Authorization', `Bearer ${accessToken}`)
    expect(res.status).toBe(200)
    expect(res.body.slots.length).toBe(9)
    expect(res.body.slots.every((s) => s.available)).toBe(true)
  })

  it('marks a slot as unavailable after a booking is created', async () => {
    const { accessToken, user } = await registerUser({ email: 'book@x.co' })
    const svcRes = await request(app)
      .post('/services')
      .set('Authorization', `Bearer ${accessToken}`)
      .send({
        tag: { en: 'lesson' },
        name: { en: 'n' },
        description: { en: 'd' },
        duration: 60,
        price: 0,
      })
    const serviceId = svcRes.body.id
    await request(app).post('/bookings').set('Authorization', `Bearer ${accessToken}`).send({
      serviceId,
      dateISO: '2099-06-16',
      time: '10:00',
      endTime: '11:00',
      durationMin: 60,
      service: 'n',
      withName: 'Client',
    })
    const res = await request(app)
      .get(`/availability/${user.id}?date=2099-06-16&duration=60`)
      .set('Authorization', `Bearer ${accessToken}`)
    const ten = res.body.slots.find((s) => s.time === '10:00')
    expect(ten.available).toBe(false)
  })
})

describe('Refresh token rotation race protection', () => {
  beforeEach(resetDb)

  it('allows only one concurrent consume of the same refresh token', async () => {
    const { refreshToken } = await registerUser({ email: 'race@x.co' })

    const responses = await Promise.all([
      request(app).post('/refresh').send({ refreshToken }),
      request(app).post('/refresh').send({ refreshToken }),
    ])

    const statuses = responses.map((res) => res.status).sort()
    expect(statuses).toEqual([200, 401])
  })
})

describe('POST/PATCH /bookings conflict protection', () => {
  beforeEach(resetDb)

  async function createService(accessToken, overrides = {}) {
    const res = await request(app)
      .post('/services')
      .set('Authorization', `Bearer ${accessToken}`)
      .send({
        tag: { en: 'lesson' },
        name: { en: 'Real service' },
        description: { en: 'real description' },
        duration: 60,
        price: 2000,
        ...overrides,
      })
    expect(res.status).toBe(201)
    return res.body
  }

  async function createBooking(accessToken, serviceId, overrides = {}) {
    return request(app)
      .post('/bookings')
      .set('Authorization', `Bearer ${accessToken}`)
      .send({
        serviceId,
        dateISO: '2099-06-16',
        time: '10:00',
        withName: 'Client',
        customerEmail: 'client@example.com',
        ...overrides,
      })
  }

  it('rejects a second booking for the same occupied slot', async () => {
    const { accessToken } = await registerUser({ email: 'conflict@x.co' })
    const service = await createService(accessToken)

    const first = await createBooking(accessToken, service.id)
    expect(first.status).toBe(201)

    const second = await createBooking(accessToken, service.id)
    expect(second.status).toBe(409)
    expect(second.body.error).toMatch(/already booked/i)
  })

  it('rejects partially overlapping bookings', async () => {
    const { accessToken } = await registerUser({ email: 'overlap@x.co' })
    const service = await createService(accessToken)

    const first = await createBooking(accessToken, service.id, { time: '10:00' })
    expect(first.status).toBe(201)

    const overlapping = await createBooking(accessToken, service.id, { time: '10:30' })
    expect(overlapping.status).toBe(409)
  })

  it('uses authoritative service duration, price and name from the server', async () => {
    const { accessToken } = await registerUser({ email: 'authoritative@x.co' })
    const service = await createService(accessToken, {
      name: { en: 'Authoritative service' },
      duration: 45,
      price: 3000,
    })

    const res = await createBooking(accessToken, service.id, {
      service: 'Fake service',
      durationMin: 999,
      endTime: '23:59',
      total: 0,
    })

    expect(res.status).toBe(201)
    expect(res.body.service).toBe('Authoritative service')
    expect(res.body.durationMin).toBe(45)
    expect(res.body.endTime).toBe('10:45')
    expect(res.body.total).toBe(3000)
  })

  it('rejects rescheduling a booking onto another occupied slot', async () => {
    const { accessToken } = await registerUser({ email: 'reschedule-conflict@x.co' })
    const service = await createService(accessToken)

    const first = await createBooking(accessToken, service.id, { time: '10:00' })
    const second = await createBooking(accessToken, service.id, { time: '12:00' })
    expect(first.status).toBe(201)
    expect(second.status).toBe(201)

    const res = await request(app)
      .patch(`/bookings/${second.body.id}`)
      .set('Authorization', `Bearer ${accessToken}`)
      .send({ dateISO: '2099-06-16', time: '10:00' })

    expect(res.status).toBe(409)
    expect(res.body.error).toMatch(/already booked/i)
  })
})

describe('Booking notification params', () => {
  beforeEach(resetDb)

  async function createServiceForNotifications(accessToken) {
    const res = await request(app)
      .post('/services')
      .set('Authorization', `Bearer ${accessToken}`)
      .send({
        tag: { en: 'lesson' },
        name: { en: 'Notification service' },
        description: { en: 'notification description' },
        duration: 60,
        price: 1000,
      })
    expect(res.status).toBe(201)
    return res.body
  }

  async function createBookingForNotifications(accessToken, serviceId, overrides = {}) {
    const res = await request(app)
      .post('/bookings')
      .set('Authorization', `Bearer ${accessToken}`)
      .send({
        serviceId,
        dateISO: '2099-06-16',
        time: '10:00',
        withName: 'Client',
        customerEmail: 'client@example.com',
        ...overrides,
      })
    expect(res.status).toBe(201)
    return res.body
  }

  it('adds bookingId to created booking notifications', async () => {
    const { accessToken } = await registerUser({ email: 'notif-created@x.co' })
    const service = await createServiceForNotifications(accessToken)
    const booking = await createBookingForNotifications(accessToken, service.id)

    const res = await request(app)
      .get('/notifications')
      .set('Authorization', `Bearer ${accessToken}`)

    expect(res.status).toBe(200)
    expect(res.body[0].kind).toBe('calendar')
    expect(res.body[0].params.bookingId).toBe(booking.id)
  })

  it('adds bookingId to cancellation notifications', async () => {
    const { accessToken } = await registerUser({ email: 'notif-cancel@x.co' })
    const service = await createServiceForNotifications(accessToken)
    const booking = await createBookingForNotifications(accessToken, service.id)

    const patch = await request(app)
      .patch(`/bookings/${booking.id}`)
      .set('Authorization', `Bearer ${accessToken}`)
      .send({ status: 'cancelled' })
    expect(patch.status).toBe(200)

    const res = await request(app)
      .get('/notifications')
      .set('Authorization', `Bearer ${accessToken}`)

    const notification = res.body.find((item) => item.kind === 'close')
    expect(notification).toBeTruthy()
    expect(notification.params.bookingId).toBe(booking.id)
    expect(notification.params.withName).toBe('Client')
  })

  it('adds old and new schedule values to reschedule notifications', async () => {
    const { accessToken } = await registerUser({ email: 'notif-reschedule@x.co' })
    const service = await createServiceForNotifications(accessToken)
    const booking = await createBookingForNotifications(accessToken, service.id, {
      dateISO: '2099-06-16',
      time: '10:00',
    })

    const patch = await request(app)
      .patch(`/bookings/${booking.id}`)
      .set('Authorization', `Bearer ${accessToken}`)
      .send({ dateISO: '2099-06-17', time: '12:00' })
    expect(patch.status).toBe(200)

    const res = await request(app)
      .get('/notifications')
      .set('Authorization', `Bearer ${accessToken}`)

    const notification = res.body.find((item) => item.kind === 'clock')
    expect(notification).toBeTruthy()
    expect(notification.params).toMatchObject({
      bookingId: booking.id,
      oldDateISO: '2099-06-16',
      oldTime: '10:00',
      newDateISO: '2099-06-17',
      newTime: '12:00',
    })
  })
})

describe('Notification deletion', () => {
  beforeEach(resetDb)

  it('deletes any owned notification', async () => {
    const { accessToken } = await registerUser({ email: 'delete-notification@x.co' })
    const serviceRes = await request(app)
      .post('/services')
      .set('Authorization', `Bearer ${accessToken}`)
      .send({
        tag: { en: 'lesson' },
        name: { en: 'Notification delete service' },
        description: { en: 'description' },
        duration: 60,
        price: 1000,
      })
    expect(serviceRes.status).toBe(201)

    const bookingRes = await request(app)
      .post('/bookings')
      .set('Authorization', `Bearer ${accessToken}`)
      .send({
        serviceId: serviceRes.body.id,
        dateISO: '2099-06-16',
        time: '10:00',
        withName: 'Client',
      })
    expect(bookingRes.status).toBe(201)

    const listBefore = await request(app)
      .get('/notifications')
      .set('Authorization', `Bearer ${accessToken}`)
    expect(listBefore.body.length).toBe(1)

    const del = await request(app)
      .delete(`/notifications/${listBefore.body[0].id}`)
      .set('Authorization', `Bearer ${accessToken}`)
    expect(del.status).toBe(204)

    const listAfter = await request(app)
      .get('/notifications')
      .set('Authorization', `Bearer ${accessToken}`)
    expect(listAfter.body).toEqual([])
  })
})
