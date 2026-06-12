// Custom Express server — libSQL (Turso / local file) + JWT with refresh rotation.
//
// Endpoints (Bearer required unless noted):
//   POST  /login, /register, /refresh, /logout
//   GET   /users/:id, PATCH /users/:id
//   GET/POST  /services            POST forces providerId from JWT
//   GET/PATCH/DELETE /services/:id  owner only
//   GET   /bookings                 current user as provider OR customer
//   GET/POST/PATCH/DELETE /bookings/:id
//   GET   /availability/:providerId?date=&duration=
//   GET   /notifications, PATCH /:id, DELETE /:id, POST /mark-all-read

import express from 'express'
import cors from 'cors'
import jwt from 'jsonwebtoken'
import bcrypt from 'bcryptjs'
import { randomBytes, createHash } from 'node:crypto'
import {
  dbGet, dbAll, dbRun,
  rowToUser, rowToService, rowToBooking, rowToNotification,
} from './db.mjs'

const PORT = Number(process.env.PORT || 3001)
const JWT_SECRET = process.env.JWT_SECRET || 'secret-key-please-change'
const JWT_EXPIRES_IN = '15m'
const REFRESH_TTL_DAYS = 30
const REFRESH_TTL_MS = REFRESH_TTL_DAYS * 24 * 60 * 60 * 1000
const BCRYPT_ROUNDS = 10
const MIN_NOTICE_MIN = 60

// Allowed origins for CORS. In dev anything goes; in prod set CORS_ORIGIN.
// Multiple origins can be comma-separated: CORS_ORIGIN=https://a.com,https://b.com
const CORS_ORIGINS = (process.env.CORS_ORIGIN || '*')
  .split(',').map(s => s.trim()).filter(Boolean)

const app = express()
app.use(cors({
  origin: CORS_ORIGINS.includes('*') ? true : CORS_ORIGINS,
  credentials: false,
}))
app.use(express.json())

// Healthcheck for Render — must respond fast, no DB calls needed.
app.get('/healthz', (_req, res) => res.json({ ok: true }))

/* ============== Auth helpers ============== */

const EMAIL_RE = /^[^@\s]+@[^@\s]+\.[^@\s]+$/

function signAccessToken(user) {
  return jwt.sign(
    { sub: String(user.id), email: user.email },
    JWT_SECRET,
    { expiresIn: JWT_EXPIRES_IN, algorithm: 'HS256' },
  )
}

function hashRefresh(plain) {
  return createHash('sha256').update(plain).digest('hex')
}

async function issueRefreshToken(userId) {
  const plain = randomBytes(48).toString('base64url')
  const tokenHash = hashRefresh(plain)
  const expiresAt = new Date(Date.now() + REFRESH_TTL_MS).toISOString()
  await dbRun(
    'INSERT INTO refresh_tokens (userId, tokenHash, expiresAt) VALUES (?, ?, ?)',
    [userId, tokenHash, expiresAt],
  )
  return plain
}

async function consumeRefreshToken(plain) {
  if (!plain || typeof plain !== 'string') return null
  const tokenHash = hashRefresh(plain)
  const row = await dbGet('SELECT * FROM refresh_tokens WHERE tokenHash = ?', [tokenHash])
  if (!row) return null
  if (new Date(row.expiresAt).getTime() < Date.now()) {
    await dbRun('DELETE FROM refresh_tokens WHERE id = ?', [Number(row.id)])
    return null
  }
  const userRow = await dbGet('SELECT * FROM users WHERE id = ?', [Number(row.userId)])
  if (!userRow) return null
  return { user: rowToUser(userRow), tokenRow: row }
}

async function purgeExpiredRefreshTokens() {
  await dbRun('DELETE FROM refresh_tokens WHERE expiresAt < ?', [new Date().toISOString()])
}
purgeExpiredRefreshTokens().catch(() => { /* ignore startup error */ })
setInterval(() => { purgeExpiredRefreshTokens().catch(() => {}) }, 24 * 60 * 60 * 1000).unref()

function parseToken(req) {
  const header = req.headers.authorization || ''
  const match = header.match(/^Bearer\s+(.+)$/)
  if (!match) return null
  try {
    const decoded = jwt.verify(match[1], JWT_SECRET, { algorithms: ['HS256'] })
    if (!decoded || typeof decoded === 'string') return null
    return { userId: Number(decoded.sub), email: decoded.email }
  } catch {
    return null
  }
}

function requireAuth(req, res, next) {
  const u = parseToken(req)
  if (!u) return res.status(401).json({ error: 'Authentication required' })
  req.user = u
  next()
}

/** Wrap an async handler so unhandled rejections become 500 instead of crashing. */
const a = (fn) => (req, res, next) => Promise.resolve(fn(req, res, next)).catch(next)

/* ============== /register, /login ============== */

app.post('/register', a(async (req, res) => {
  const { email, password, name } = req.body || {}
  if (!email || !EMAIL_RE.test(String(email))) return res.status(400).json({ error: 'Valid email required' })
  if (!password || String(password).length < 6) return res.status(400).json({ error: 'Password must be at least 6 characters' })
  if (!name || !String(name).trim()) return res.status(400).json({ error: 'Name required' })

  const passwordHash = bcrypt.hashSync(String(password), BCRYPT_ROUNDS)
  let info
  try {
    info = await dbRun(
      'INSERT INTO users (email, passwordHash, name) VALUES (?, ?, ?)',
      [String(email).toLowerCase(), passwordHash, String(name).trim()],
    )
  } catch (e) {
    if (String(e.message).includes('UNIQUE')) return res.status(400).json({ error: 'Email already exists' })
    return res.status(500).json({ error: 'Could not create user' })
  }
  const userRow = await dbGet('SELECT * FROM users WHERE id = ?', [info.lastInsertRowid])
  const user = rowToUser(userRow)
  res.status(201).json({
    accessToken: signAccessToken(user),
    refreshToken: await issueRefreshToken(user.id),
    user,
  })
}))

app.post('/login', a(async (req, res) => {
  const { email, password } = req.body || {}
  if (!email || !password) return res.status(400).json({ error: 'Email and password required' })
  const row = await dbGet('SELECT * FROM users WHERE email = ?', [String(email).toLowerCase()])
  if (!row || !bcrypt.compareSync(String(password), row.passwordHash)) {
    return res.status(400).json({ error: 'Incorrect email or password' })
  }
  const user = rowToUser(row)
  res.json({
    accessToken: signAccessToken(user),
    refreshToken: await issueRefreshToken(user.id),
    user,
  })
}))

app.post('/refresh', a(async (req, res) => {
  const session = await consumeRefreshToken(req.body?.refreshToken)
  if (!session) return res.status(401).json({ error: 'Invalid or expired refresh token' })
  await dbRun('DELETE FROM refresh_tokens WHERE id = ?', [Number(session.tokenRow.id)])
  res.json({
    accessToken: signAccessToken(session.user),
    refreshToken: await issueRefreshToken(session.user.id),
    user: session.user,
  })
}))

app.post('/logout', a(async (req, res) => {
  const presented = req.body?.refreshToken
  if (presented) {
    await dbRun('DELETE FROM refresh_tokens WHERE tokenHash = ?', [hashRefresh(presented)])
  }
  res.json({ ok: true })
}))

/* ============== /users ============== */

app.get('/users/:id', requireAuth, a(async (req, res) => {
  const id = Number(req.params.id)
  if (id !== req.user.userId) return res.status(403).json({ error: 'Forbidden' })
  const row = await dbGet('SELECT * FROM users WHERE id = ?', [id])
  if (!row) return res.status(404).json({ error: 'User not found' })
  res.json(rowToUser(row))
}))

app.patch('/users/:id', requireAuth, a(async (req, res) => {
  const id = Number(req.params.id)
  if (id !== req.user.userId) return res.status(403).json({ error: 'Forbidden' })
  const allowed = ['name', 'displayName', 'phone', 'timezone', 'bio', 'workingHours']
  const sets = []
  const values = []
  for (const k of allowed) {
    if (!(k in (req.body || {}))) continue
    sets.push(`${k} = ?`)
    const v = req.body[k]
    values.push(k === 'workingHours' && v !== null ? JSON.stringify(v) : v)
  }
  if (sets.length) {
    values.push(id)
    await dbRun(`UPDATE users SET ${sets.join(', ')} WHERE id = ?`, values)
  }
  const row = await dbGet('SELECT * FROM users WHERE id = ?', [id])
  res.json(rowToUser(row))
}))

/* ============== /services ============== */

app.get('/services', requireAuth, a(async (req, res) => {
  const rows = await dbAll('SELECT * FROM services WHERE providerId = ? ORDER BY id', [req.user.userId])
  res.json(rows.map(rowToService))
}))

app.get('/services/:id', requireAuth, a(async (req, res) => {
  const row = await dbGet('SELECT * FROM services WHERE id = ?', [Number(req.params.id)])
  if (!row) return res.status(404).json({ error: 'Service not found' })
  if (Number(row.providerId) !== req.user.userId) return res.status(403).json({ error: 'Not the owner' })
  res.json(rowToService(row))
}))

function validateServicePayload(body) {
  const errs = []
  if (!body || typeof body !== 'object') return ['payload required']
  if (!body.tag || typeof body.tag !== 'object') errs.push('tag required')
  if (!body.name || typeof body.name !== 'object') errs.push('name required')
  if (!body.description || typeof body.description !== 'object') errs.push('description required')
  if (!Number.isFinite(Number(body.duration)) || Number(body.duration) <= 0) errs.push('duration must be > 0')
  if (!Number.isFinite(Number(body.price)) || Number(body.price) < 0) errs.push('price must be >= 0')
  return errs
}

app.post('/services', requireAuth, a(async (req, res) => {
  const errs = validateServicePayload(req.body)
  if (errs.length) return res.status(400).json({ error: errs.join('; ') })
  const info = await dbRun(`
    INSERT INTO services (providerId, tag, tone, duration, price, name, description)
    VALUES (?, ?, ?, ?, ?, ?, ?)
  `, [
    req.user.userId,
    JSON.stringify(req.body.tag),
    String(req.body.tone || 'muted'),
    Number(req.body.duration),
    Number(req.body.price),
    JSON.stringify(req.body.name),
    JSON.stringify(req.body.description),
  ])
  const row = await dbGet('SELECT * FROM services WHERE id = ?', [info.lastInsertRowid])
  res.status(201).json(rowToService(row))
}))

app.patch('/services/:id', requireAuth, a(async (req, res) => {
  const id = Number(req.params.id)
  const existing = await dbGet('SELECT * FROM services WHERE id = ?', [id])
  if (!existing) return res.status(404).json({ error: 'Service not found' })
  if (Number(existing.providerId) !== req.user.userId) return res.status(403).json({ error: 'Not the owner' })
  const allowed = ['tag', 'tone', 'duration', 'price', 'name', 'description']
  const sets = []
  const values = []
  for (const k of allowed) {
    if (!(k in (req.body || {}))) continue
    sets.push(`${k} = ?`)
    values.push(['tag', 'name', 'description'].includes(k) ? JSON.stringify(req.body[k]) : req.body[k])
  }
  if (sets.length) {
    values.push(id)
    await dbRun(`UPDATE services SET ${sets.join(', ')} WHERE id = ?`, values)
  }
  const updated = await dbGet('SELECT * FROM services WHERE id = ?', [id])
  res.json(rowToService(updated))
}))

app.delete('/services/:id', requireAuth, a(async (req, res) => {
  const id = Number(req.params.id)
  const existing = await dbGet('SELECT * FROM services WHERE id = ?', [id])
  if (!existing) return res.status(404).json({ error: 'Service not found' })
  if (Number(existing.providerId) !== req.user.userId) return res.status(403).json({ error: 'Not the owner' })
  await dbRun('DELETE FROM services WHERE id = ?', [id])
  res.status(204).end()
}))

/* ============== /bookings ============== */

async function pushNotification(userId, kind, params, tone) {
  await dbRun(`
    INSERT INTO notifications (userId, kind, tone, params, unread)
    VALUES (?, ?, ?, ?, 1)
  `, [userId, kind, tone || 'muted', JSON.stringify(params || {})])
}

app.get('/bookings', requireAuth, a(async (req, res) => {
  const me = req.user.userId
  const rows = await dbAll(`
    SELECT * FROM bookings WHERE providerId = ? OR customerId = ? ORDER BY dateISO, time
  `, [me, me])
  res.json(rows.map(rowToBooking))
}))

app.get('/bookings/:id', requireAuth, a(async (req, res) => {
  const row = await dbGet('SELECT * FROM bookings WHERE id = ?', [Number(req.params.id)])
  if (!row) return res.status(404).json({ error: 'Booking not found' })
  const me = req.user.userId
  if (Number(row.providerId) !== me && Number(row.customerId) !== me) {
    return res.status(403).json({ error: 'Forbidden' })
  }
  res.json(rowToBooking(row))
}))

app.post('/bookings', requireAuth, a(async (req, res) => {
  const b = req.body || {}
  const serviceId = Number(b.serviceId)
  if (!serviceId) return res.status(400).json({ error: 'serviceId required' })
  const service = await dbGet('SELECT * FROM services WHERE id = ?', [serviceId])
  if (!service) return res.status(400).json({ error: 'Unknown serviceId' })
  if (Number(service.providerId) !== req.user.userId) {
    return res.status(403).json({ error: 'Cannot book another user\'s service' })
  }
  const info = await dbRun(`
    INSERT INTO bookings (
      providerId, customerId, serviceId,
      dateISO, time, endTime, durationMin, service, total, status,
      withName, initials, customerEmail, customerPhone, notes
    ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
  `, [
    Number(service.providerId), req.user.userId, serviceId,
    String(b.dateISO || ''), String(b.time || ''), b.endTime || null,
    Number(b.durationMin) || 60, String(b.service || ''), Number(b.total) || 0,
    String(b.status || 'confirmed'), String(b.withName || ''), String(b.initials || ''),
    String(b.customerEmail || ''), b.customerPhone || null, b.notes || null,
  ])
  const row = await dbGet('SELECT * FROM bookings WHERE id = ?', [info.lastInsertRowid])
  await pushNotification(req.user.userId, 'calendar', {
    service: row.service, withName: row.withName, dateISO: row.dateISO, time: row.time,
  }, 'accent')
  res.status(201).json(rowToBooking(row))
}))

app.patch('/bookings/:id', requireAuth, a(async (req, res) => {
  const id = Number(req.params.id)
  const existing = await dbGet('SELECT * FROM bookings WHERE id = ?', [id])
  if (!existing) return res.status(404).json({ error: 'Booking not found' })
  if (Number(existing.providerId) !== req.user.userId) {
    return res.status(403).json({ error: 'Only the provider can modify this booking' })
  }
  const allowed = ['dateISO', 'time', 'endTime', 'durationMin', 'status',
    'withName', 'initials', 'customerEmail', 'customerPhone', 'notes', 'service', 'total']
  const sets = []
  const values = []
  for (const k of allowed) {
    if (!(k in (req.body || {}))) continue
    sets.push(`${k} = ?`)
    values.push(req.body[k])
  }
  if (sets.length) {
    values.push(id)
    await dbRun(`UPDATE bookings SET ${sets.join(', ')} WHERE id = ?`, values)
  }
  const updated = await dbGet('SELECT * FROM bookings WHERE id = ?', [id])

  if (updated.status === 'cancelled' && existing.status !== 'cancelled') {
    await pushNotification(req.user.userId, 'close', {
      service: updated.service, dateISO: updated.dateISO, time: updated.time,
    }, 'danger')
  } else if (updated.time !== existing.time || updated.dateISO !== existing.dateISO) {
    await pushNotification(req.user.userId, 'clock', {
      service: updated.service, dateISO: updated.dateISO, time: updated.time,
    }, 'accent')
  }
  res.json(rowToBooking(updated))
}))

app.delete('/bookings/:id', requireAuth, a(async (req, res) => {
  const id = Number(req.params.id)
  const existing = await dbGet('SELECT * FROM bookings WHERE id = ?', [id])
  if (!existing) return res.status(404).json({ error: 'Booking not found' })
  if (Number(existing.providerId) !== req.user.userId) {
    return res.status(403).json({ error: 'Only the provider can delete this booking' })
  }
  await dbRun('DELETE FROM bookings WHERE id = ?', [id])
  res.status(204).end()
}))

/* ============== /availability ============== */

const DAY_KEYS = ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun']
const DEFAULT_WORKING_HOURS = {
  mon: { start: '09:00', end: '18:00' },
  tue: { start: '09:00', end: '18:00' },
  wed: { start: '09:00', end: '18:00' },
  thu: { start: '09:00', end: '18:00' },
  fri: { start: '09:00', end: '18:00' },
}

const hhmmToMin = s => { const [h, m] = String(s).split(':').map(Number); return h * 60 + m }
const minToHHMM = min => `${String(Math.floor(min / 60) % 24).padStart(2, '0')}:${String(min % 60).padStart(2, '0')}`

function normalizeWorkingHours(wh) {
  if (!wh || typeof wh !== 'object') return DEFAULT_WORKING_HOURS
  if (typeof wh.start === 'string' && typeof wh.end === 'string') {
    return DAY_KEYS.slice(0, 5).reduce((acc, k) => (acc[k] = { start: wh.start, end: wh.end }, acc), {})
  }
  const hasAnyDay = DAY_KEYS.some(k => wh[k])
  if (!hasAnyDay) return DEFAULT_WORKING_HOURS
  return wh
}

function dowKeyFromISO(iso) {
  const [y, m, d] = iso.split('-').map(Number)
  const jsDow = new Date(y, m - 1, d).getDay()
  return DAY_KEYS[jsDow === 0 ? 6 : jsDow - 1]
}

app.get('/availability/:providerId', requireAuth, a(async (req, res) => {
  const providerId = Number(req.params.providerId)
  const dateISO = String(req.query.date || '')
  const duration = Number(req.query.duration) || 60

  if (!/^\d{4}-\d{2}-\d{2}$/.test(dateISO)) {
    return res.status(400).json({ error: 'date query param required as YYYY-MM-DD' })
  }
  const provider = await dbGet('SELECT * FROM users WHERE id = ?', [providerId])
  if (!provider) return res.status(404).json({ error: 'Provider not found' })

  const wh = normalizeWorkingHours(provider.workingHours ? JSON.parse(provider.workingHours) : undefined)
  const dayKey = dowKeyFromISO(dateISO)
  const hasOwn = Object.prototype.hasOwnProperty.call(wh, dayKey)
  const window = hasOwn ? wh[dayKey] : (DEFAULT_WORKING_HOURS[dayKey] || null)
  if (!window) return res.json({ slots: [], workingHours: null })

  const startMin = hhmmToMin(window.start)
  const endMin = hhmmToMin(window.end)

  const blockingRows = await dbAll(`
    SELECT time, endTime, durationMin FROM bookings
    WHERE providerId = ? AND dateISO = ? AND status != 'cancelled'
  `, [providerId, dateISO])
  const blocking = blockingRows.map(b => {
    const s = hhmmToMin(b.time)
    const e = b.endTime ? hhmmToMin(b.endTime) : s + (Number(b.durationMin) || 60)
    return [s, e]
  })

  const now = new Date()
  const todayISO = `${now.getFullYear()}-${String(now.getMonth() + 1).padStart(2, '0')}-${String(now.getDate()).padStart(2, '0')}`
  const cutoffMin = dateISO === todayISO ? now.getHours() * 60 + now.getMinutes() + MIN_NOTICE_MIN : -Infinity

  const STEP = 60
  const slots = []
  for (let s = startMin; s + duration <= endMin; s += STEP) {
    const e = s + duration
    let available = true
    if (s < cutoffMin) available = false
    else for (const [bs, be] of blocking) if (s < be && bs < e) { available = false; break }
    slots.push({ time: minToHHMM(s), available })
  }
  res.json({ slots, workingHours: window })
}))

/* ============== /notifications ============== */

app.get('/notifications', requireAuth, a(async (req, res) => {
  const rows = await dbAll(`
    SELECT * FROM notifications WHERE userId = ? ORDER BY createdAt DESC
  `, [req.user.userId])
  res.json(rows.map(rowToNotification))
}))

app.patch('/notifications/:id', requireAuth, a(async (req, res) => {
  const id = Number(req.params.id)
  const row = await dbGet('SELECT * FROM notifications WHERE id = ?', [id])
  if (!row) return res.status(404).json({ error: 'Notification not found' })
  if (Number(row.userId) !== req.user.userId) return res.status(403).json({ error: 'Not the owner' })
  if (typeof req.body?.unread === 'boolean') {
    await dbRun('UPDATE notifications SET unread = ? WHERE id = ?', [req.body.unread ? 1 : 0, id])
  }
  const updated = await dbGet('SELECT * FROM notifications WHERE id = ?', [id])
  res.json(rowToNotification(updated))
}))

app.post('/notifications/mark-all-read', requireAuth, a(async (req, res) => {
  await dbRun('UPDATE notifications SET unread = 0 WHERE userId = ? AND unread = 1', [req.user.userId])
  res.json({ ok: true })
}))

app.delete('/notifications/:id', requireAuth, a(async (req, res) => {
  const id = Number(req.params.id)
  const row = await dbGet('SELECT * FROM notifications WHERE id = ?', [id])
  if (!row) return res.status(404).json({ error: 'Notification not found' })
  if (Number(row.userId) !== req.user.userId) return res.status(403).json({ error: 'Not the owner' })
  await dbRun('DELETE FROM notifications WHERE id = ?', [id])
  res.status(204).end()
}))

/* ============== Generic error handler ============== */

// eslint-disable-next-line no-unused-vars
app.use((err, req, res, _next) => {
  console.error('[error]', err)
  res.status(500).json({ error: 'Internal server error' })
})

/* ============== Boot ============== */

app.listen(PORT, () => {
  const dbInfo = process.env.TURSO_DATABASE_URL ? 'Turso (remote)' : 'local file ./slottr.db'
  console.log(`  \\{^_^}/  Slottr API on port ${PORT}`)
  console.log(`  DB:      ${dbInfo}`)
  console.log(`  CORS:    ${CORS_ORIGINS.join(', ')}`)
  console.log(`  JWT:     HS256, exp ${JWT_EXPIRES_IN}${process.env.JWT_SECRET ? '' : ' (DEFAULT secret — set JWT_SECRET in prod!)'}`)
})
