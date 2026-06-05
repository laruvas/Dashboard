// Custom Express server — SQLite + JWT.
//
// Replaces the previous json-server + json-server-auth stack:
//   - SQLite (better-sqlite3) for persistence with foreign keys (orphan-proof)
//   - bcryptjs for password hashing
//   - jsonwebtoken with HS256 + verified signature (no more jwt.decode)
//
// Endpoints (Bearer required unless noted):
//   POST  /login,  /register        — public; returns {accessToken, user}
//   GET   /users/:id, PATCH same
//   GET   /services                 — owned by current user
//   GET   /services/:id             — owner only
//   POST  /services                 — providerId forced from JWT
//   PATCH/DELETE /services/:id      — owner only
//   GET   /bookings                 — current user as provider OR customer
//   GET   /bookings/:id, POST, PATCH, DELETE
//   GET   /availability/:providerId?date=&duration=
//   GET   /notifications, PATCH /:id, DELETE /:id, POST /mark-all-read

import express from 'express'
import cors from 'cors'
import jwt from 'jsonwebtoken'
import bcrypt from 'bcryptjs'
import { randomBytes, createHash } from 'node:crypto'
import {
  db, rowToUser, rowToService, rowToBooking, rowToNotification,
} from './db.mjs'

const PORT = Number(process.env.PORT || 3001)
// Keep the same default as before so existing tokens stay valid across restarts.
const JWT_SECRET = process.env.JWT_SECRET || 'secret-key-please-change'
const JWT_EXPIRES_IN = '15m'                   // short-lived: stolen access expires fast
const REFRESH_TTL_DAYS = 30                     // long-lived: stays in DB, rotated on use
const REFRESH_TTL_MS = REFRESH_TTL_DAYS * 24 * 60 * 60 * 1000
const BCRYPT_ROUNDS = 10
const MIN_NOTICE_MIN = 60

const app = express()
app.use(cors())
app.use(express.json())

/* ============== Helpers ============== */

const EMAIL_RE = /^[^@\s]+@[^@\s]+\.[^@\s]+$/

function signAccessToken(user) {
  return jwt.sign(
    { sub: String(user.id), email: user.email },
    JWT_SECRET,
    { expiresIn: JWT_EXPIRES_IN, algorithm: 'HS256' },
  )
}

/** Hash a refresh token before storing — so a leaked DB dump can't impersonate sessions. */
function hashRefresh(plain) {
  return createHash('sha256').update(plain).digest('hex')
}

/**
 * Mint a new refresh token, persist its hash, return the plain value.
 * Caller is expected to bundle it with the access token in the response.
 */
function issueRefreshToken(userId) {
  const plain = randomBytes(48).toString('base64url')  // 64 chars, URL-safe
  const tokenHash = hashRefresh(plain)
  const expiresAt = new Date(Date.now() + REFRESH_TTL_MS).toISOString()
  db.prepare('INSERT INTO refresh_tokens (userId, tokenHash, expiresAt) VALUES (?, ?, ?)')
    .run(userId, tokenHash, expiresAt)
  return plain
}

/** Returns { user, row } if token is valid and not expired, otherwise null. */
function consumeRefreshToken(plain) {
  if (!plain || typeof plain !== 'string') return null
  const tokenHash = hashRefresh(plain)
  const row = db.prepare('SELECT * FROM refresh_tokens WHERE tokenHash = ?').get(tokenHash)
  if (!row) return null
  if (new Date(row.expiresAt).getTime() < Date.now()) {
    // Expired — clean up.
    db.prepare('DELETE FROM refresh_tokens WHERE id = ?').run(row.id)
    return null
  }
  const userRow = db.prepare('SELECT * FROM users WHERE id = ?').get(row.userId)
  if (!userRow) return null
  return { user: rowToUser(userRow), tokenRow: row }
}

/** Best-effort cleanup of expired tokens; called occasionally. */
function purgeExpiredRefreshTokens() {
  db.prepare('DELETE FROM refresh_tokens WHERE expiresAt < ?').run(new Date().toISOString())
}
purgeExpiredRefreshTokens()
setInterval(purgeExpiredRefreshTokens, 24 * 60 * 60 * 1000).unref()

function parseToken(req) {
  const header = req.headers.authorization || ''
  const match = header.match(/^Bearer\s+(.+)$/)
  if (!match) return null
  try {
    // Verify (not decode) — rejects tampered tokens and expired ones.
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

/* ============== Auth ============== */

app.post('/register', (req, res) => {
  const { email, password, name } = req.body || {}
  if (!email || !EMAIL_RE.test(String(email))) return res.status(400).json({ error: 'Valid email required' })
  if (!password || String(password).length < 6) return res.status(400).json({ error: 'Password must be at least 6 characters' })
  if (!name || !String(name).trim()) return res.status(400).json({ error: 'Name required' })

  const passwordHash = bcrypt.hashSync(String(password), BCRYPT_ROUNDS)
  let info
  try {
    info = db.prepare('INSERT INTO users (email, passwordHash, name) VALUES (?, ?, ?)')
      .run(String(email).toLowerCase(), passwordHash, String(name).trim())
  } catch (e) {
    if (String(e.message).includes('UNIQUE')) return res.status(400).json({ error: 'Email already exists' })
    return res.status(500).json({ error: 'Could not create user' })
  }
  const user = rowToUser(db.prepare('SELECT * FROM users WHERE id = ?').get(info.lastInsertRowid))
  res.status(201).json({
    accessToken: signAccessToken(user),
    refreshToken: issueRefreshToken(user.id),
    user,
  })
})

app.post('/login', (req, res) => {
  const { email, password } = req.body || {}
  if (!email || !password) return res.status(400).json({ error: 'Email and password required' })
  const row = db.prepare('SELECT * FROM users WHERE email = ?').get(String(email).toLowerCase())
  if (!row || !bcrypt.compareSync(String(password), row.passwordHash)) {
    return res.status(400).json({ error: 'Incorrect email or password' })
  }
  const user = rowToUser(row)
  res.json({
    accessToken: signAccessToken(user),
    refreshToken: issueRefreshToken(user.id),
    user,
  })
})

/**
 * POST /refresh — exchange a refresh token for a new pair.
 * Rotation: the presented refresh token is invalidated immediately, and a fresh
 * pair is issued. If an attacker stole an old refresh and used it, the legitimate
 * client's next /refresh will fail — surfacing the breach.
 */
app.post('/refresh', (req, res) => {
  const presented = req.body?.refreshToken
  const session = consumeRefreshToken(presented)
  if (!session) return res.status(401).json({ error: 'Invalid or expired refresh token' })
  // Rotate: delete the consumed token, issue a new one.
  db.prepare('DELETE FROM refresh_tokens WHERE id = ?').run(session.tokenRow.id)
  res.json({
    accessToken: signAccessToken(session.user),
    refreshToken: issueRefreshToken(session.user.id),
    user: session.user,
  })
})

/**
 * POST /logout — invalidate the presented refresh token.
 * Access tokens can't be revoked (stateless JWT), but they expire in 15 min.
 * Best-effort: returns 200 even if token doesn't exist (idempotent).
 */
app.post('/logout', (req, res) => {
  const presented = req.body?.refreshToken
  if (presented) {
    const tokenHash = hashRefresh(presented)
    db.prepare('DELETE FROM refresh_tokens WHERE tokenHash = ?').run(tokenHash)
  }
  res.json({ ok: true })
})

/* ============== Users ============== */

app.get('/users/:id', requireAuth, (req, res) => {
  const id = Number(req.params.id)
  if (id !== req.user.userId) return res.status(403).json({ error: 'Forbidden' })
  const row = db.prepare('SELECT * FROM users WHERE id = ?').get(id)
  if (!row) return res.status(404).json({ error: 'User not found' })
  res.json(rowToUser(row))
})

app.patch('/users/:id', requireAuth, (req, res) => {
  const id = Number(req.params.id)
  if (id !== req.user.userId) return res.status(403).json({ error: 'Forbidden' })

  // Whitelist mutable fields. Ignore id/email/passwordHash/createdAt.
  const allowed = ['name', 'displayName', 'phone', 'timezone', 'bio', 'workingHours']
  const sets = []
  const values = []
  for (const k of allowed) {
    if (!(k in (req.body || {}))) continue
    sets.push(`${k} = ?`)
    const v = req.body[k]
    values.push(k === 'workingHours' && v !== null ? JSON.stringify(v) : v)
  }
  if (sets.length === 0) {
    const row = db.prepare('SELECT * FROM users WHERE id = ?').get(id)
    return res.json(rowToUser(row))
  }
  values.push(id)
  db.prepare(`UPDATE users SET ${sets.join(', ')} WHERE id = ?`).run(...values)
  const row = db.prepare('SELECT * FROM users WHERE id = ?').get(id)
  res.json(rowToUser(row))
})

/* ============== Services ============== */

app.get('/services', requireAuth, (req, res) => {
  const rows = db.prepare('SELECT * FROM services WHERE providerId = ? ORDER BY id').all(req.user.userId)
  res.json(rows.map(rowToService))
})

app.get('/services/:id', requireAuth, (req, res) => {
  const row = db.prepare('SELECT * FROM services WHERE id = ?').get(Number(req.params.id))
  if (!row) return res.status(404).json({ error: 'Service not found' })
  if (row.providerId !== req.user.userId) return res.status(403).json({ error: 'Not the owner' })
  res.json(rowToService(row))
})

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

app.post('/services', requireAuth, (req, res) => {
  const errs = validateServicePayload(req.body)
  if (errs.length) return res.status(400).json({ error: errs.join('; ') })
  const info = db.prepare(`
    INSERT INTO services (providerId, tag, tone, duration, price, name, description)
    VALUES (?, ?, ?, ?, ?, ?, ?)
  `).run(
    req.user.userId,
    JSON.stringify(req.body.tag),
    String(req.body.tone || 'muted'),
    Number(req.body.duration),
    Number(req.body.price),
    JSON.stringify(req.body.name),
    JSON.stringify(req.body.description),
  )
  const row = db.prepare('SELECT * FROM services WHERE id = ?').get(info.lastInsertRowid)
  res.status(201).json(rowToService(row))
})

app.patch('/services/:id', requireAuth, (req, res) => {
  const id = Number(req.params.id)
  const existing = db.prepare('SELECT * FROM services WHERE id = ?').get(id)
  if (!existing) return res.status(404).json({ error: 'Service not found' })
  if (existing.providerId !== req.user.userId) return res.status(403).json({ error: 'Not the owner' })

  const allowed = ['tag', 'tone', 'duration', 'price', 'name', 'description']
  const sets = []
  const values = []
  for (const k of allowed) {
    if (!(k in (req.body || {}))) continue
    sets.push(`${k} = ?`)
    const v = req.body[k]
    values.push(['tag', 'name', 'description'].includes(k) ? JSON.stringify(v) : v)
  }
  if (sets.length === 0) return res.json(rowToService(existing))
  values.push(id)
  db.prepare(`UPDATE services SET ${sets.join(', ')} WHERE id = ?`).run(...values)
  res.json(rowToService(db.prepare('SELECT * FROM services WHERE id = ?').get(id)))
})

app.delete('/services/:id', requireAuth, (req, res) => {
  const id = Number(req.params.id)
  const existing = db.prepare('SELECT * FROM services WHERE id = ?').get(id)
  if (!existing) return res.status(404).json({ error: 'Service not found' })
  if (existing.providerId !== req.user.userId) return res.status(403).json({ error: 'Not the owner' })
  db.prepare('DELETE FROM services WHERE id = ?').run(id)
  res.status(204).end()
})

/* ============== Bookings ============== */

function pushNotification(userId, kind, params, tone) {
  db.prepare(`
    INSERT INTO notifications (userId, kind, tone, params, unread)
    VALUES (?, ?, ?, ?, 1)
  `).run(userId, kind, tone || 'muted', JSON.stringify(params || {}))
}

app.get('/bookings', requireAuth, (req, res) => {
  const me = req.user.userId
  const rows = db.prepare(`
    SELECT * FROM bookings WHERE providerId = ? OR customerId = ? ORDER BY dateISO, time
  `).all(me, me)
  res.json(rows.map(rowToBooking))
})

app.get('/bookings/:id', requireAuth, (req, res) => {
  const row = db.prepare('SELECT * FROM bookings WHERE id = ?').get(Number(req.params.id))
  if (!row) return res.status(404).json({ error: 'Booking not found' })
  const me = req.user.userId
  if (row.providerId !== me && row.customerId !== me) {
    return res.status(403).json({ error: 'Forbidden' })
  }
  res.json(rowToBooking(row))
})

app.post('/bookings', requireAuth, (req, res) => {
  const b = req.body || {}
  const serviceId = Number(b.serviceId)
  if (!serviceId) return res.status(400).json({ error: 'serviceId required' })
  const service = db.prepare('SELECT * FROM services WHERE id = ?').get(serviceId)
  if (!service) return res.status(400).json({ error: 'Unknown serviceId' })
  if (service.providerId !== req.user.userId) {
    return res.status(403).json({ error: 'Cannot book another user\'s service' })
  }

  const info = db.prepare(`
    INSERT INTO bookings (
      providerId, customerId, serviceId,
      dateISO, time, endTime, durationMin, service, total, status,
      withName, initials, customerEmail, customerPhone, notes
    ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
  `).run(
    service.providerId,            // forced from service
    req.user.userId,               // forced from JWT
    serviceId,
    String(b.dateISO || ''),
    String(b.time || ''),
    b.endTime || null,
    Number(b.durationMin) || 60,
    String(b.service || ''),
    Number(b.total) || 0,
    String(b.status || 'confirmed'),
    String(b.withName || ''),
    String(b.initials || ''),
    String(b.customerEmail || ''),
    b.customerPhone || null,
    b.notes || null,
  )
  const row = db.prepare('SELECT * FROM bookings WHERE id = ?').get(info.lastInsertRowid)
  pushNotification(req.user.userId, 'calendar', {
    service: row.service, withName: row.withName, dateISO: row.dateISO, time: row.time,
  }, 'accent')
  res.status(201).json(rowToBooking(row))
})

app.patch('/bookings/:id', requireAuth, (req, res) => {
  const id = Number(req.params.id)
  const existing = db.prepare('SELECT * FROM bookings WHERE id = ?').get(id)
  if (!existing) return res.status(404).json({ error: 'Booking not found' })
  if (existing.providerId !== req.user.userId) {
    return res.status(403).json({ error: 'Only the provider can modify this booking' })
  }

  // Whitelist; never let the client change ownership or createdAt.
  const allowed = ['dateISO', 'time', 'endTime', 'durationMin', 'status',
    'withName', 'initials', 'customerEmail', 'customerPhone', 'notes', 'service', 'total']
  const sets = []
  const values = []
  for (const k of allowed) {
    if (!(k in (req.body || {}))) continue
    sets.push(`${k} = ?`)
    values.push(req.body[k])
  }
  if (sets.length === 0) return res.json(rowToBooking(existing))
  values.push(id)
  db.prepare(`UPDATE bookings SET ${sets.join(', ')} WHERE id = ?`).run(...values)
  const updated = db.prepare('SELECT * FROM bookings WHERE id = ?').get(id)

  // Notifications: cancel vs reschedule.
  const wasStatus = existing.status
  const newStatus = updated.status
  if (newStatus === 'cancelled' && wasStatus !== 'cancelled') {
    pushNotification(req.user.userId, 'close', {
      service: updated.service, dateISO: updated.dateISO, time: updated.time,
    }, 'danger')
  } else if (updated.time !== existing.time || updated.dateISO !== existing.dateISO) {
    pushNotification(req.user.userId, 'clock', {
      service: updated.service, dateISO: updated.dateISO, time: updated.time,
    }, 'accent')
  }
  res.json(rowToBooking(updated))
})

app.delete('/bookings/:id', requireAuth, (req, res) => {
  const id = Number(req.params.id)
  const existing = db.prepare('SELECT * FROM bookings WHERE id = ?').get(id)
  if (!existing) return res.status(404).json({ error: 'Booking not found' })
  if (existing.providerId !== req.user.userId) {
    return res.status(403).json({ error: 'Only the provider can delete this booking' })
  }
  db.prepare('DELETE FROM bookings WHERE id = ?').run(id)
  res.status(204).end()
})

/* ============== Availability ============== */

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

app.get('/availability/:providerId', requireAuth, (req, res) => {
  const providerId = Number(req.params.providerId)
  const dateISO = String(req.query.date || '')
  const duration = Number(req.query.duration) || 60

  if (!/^\d{4}-\d{2}-\d{2}$/.test(dateISO)) {
    return res.status(400).json({ error: 'date query param required as YYYY-MM-DD' })
  }
  const provider = db.prepare('SELECT * FROM users WHERE id = ?').get(providerId)
  if (!provider) return res.status(404).json({ error: 'Provider not found' })

  const wh = normalizeWorkingHours(provider.workingHours ? JSON.parse(provider.workingHours) : undefined)
  const dayKey = dowKeyFromISO(dateISO)
  const hasOwn = Object.prototype.hasOwnProperty.call(wh, dayKey)
  const window = hasOwn ? wh[dayKey] : (DEFAULT_WORKING_HOURS[dayKey] || null)
  if (!window) return res.json({ slots: [], workingHours: null })

  const startMin = hhmmToMin(window.start)
  const endMin = hhmmToMin(window.end)

  const blocking = db.prepare(`
    SELECT time, endTime, durationMin FROM bookings
    WHERE providerId = ? AND dateISO = ? AND status != 'cancelled'
  `).all(providerId, dateISO).map(b => {
    const s = hhmmToMin(b.time)
    const e = b.endTime ? hhmmToMin(b.endTime) : s + (b.durationMin || 60)
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
})

/* ============== Notifications ============== */

app.get('/notifications', requireAuth, (req, res) => {
  const rows = db.prepare(`
    SELECT * FROM notifications WHERE userId = ? ORDER BY createdAt DESC
  `).all(req.user.userId)
  res.json(rows.map(rowToNotification))
})

app.patch('/notifications/:id', requireAuth, (req, res) => {
  const id = Number(req.params.id)
  const row = db.prepare('SELECT * FROM notifications WHERE id = ?').get(id)
  if (!row) return res.status(404).json({ error: 'Notification not found' })
  if (row.userId !== req.user.userId) return res.status(403).json({ error: 'Not the owner' })
  if (typeof req.body?.unread === 'boolean') {
    db.prepare('UPDATE notifications SET unread = ? WHERE id = ?').run(req.body.unread ? 1 : 0, id)
  }
  res.json(rowToNotification(db.prepare('SELECT * FROM notifications WHERE id = ?').get(id)))
})

app.post('/notifications/mark-all-read', requireAuth, (req, res) => {
  db.prepare('UPDATE notifications SET unread = 0 WHERE userId = ? AND unread = 1').run(req.user.userId)
  res.json({ ok: true })
})

app.delete('/notifications/:id', requireAuth, (req, res) => {
  const id = Number(req.params.id)
  const row = db.prepare('SELECT * FROM notifications WHERE id = ?').get(id)
  if (!row) return res.status(404).json({ error: 'Notification not found' })
  if (row.userId !== req.user.userId) return res.status(403).json({ error: 'Not the owner' })
  db.prepare('DELETE FROM notifications WHERE id = ?').run(id)
  res.status(204).end()
})

/* ============== Boot ============== */

app.listen(PORT, () => {
  console.log(`  \\{^_^}/  Slottr API on http://localhost:${PORT}`)
  console.log(`  SQLite:  ./slottr.db`)
  console.log(`  JWT:     HS256, exp ${JWT_EXPIRES_IN}${process.env.JWT_SECRET ? '' : ' (using DEFAULT secret — set JWT_SECRET in prod)'}`)
})
