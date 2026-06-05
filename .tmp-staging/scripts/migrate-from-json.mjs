// One-shot migration: db.json (legacy json-server) → slottr.db (SQLite).
// Idempotent: safe to re-run, skips rows that already exist (by email/id).
//
// Run:  node scripts/migrate-from-json.mjs

import { readFileSync, existsSync } from 'node:fs'
import { resolve, dirname } from 'node:path'
import { fileURLToPath } from 'node:url'
import { db } from './db.mjs'

const __dirname = dirname(fileURLToPath(import.meta.url))
const SOURCE = resolve(__dirname, '..', 'db.json')

if (!existsSync(SOURCE)) {
  console.log('No db.json found — nothing to migrate.')
  process.exit(0)
}

const data = JSON.parse(readFileSync(SOURCE, 'utf8'))

const users = data.users || []
const services = data.services || []
const bookings = data.bookings || []
const notifications = data.notifications || []

let movedUsers = 0, movedSvcs = 0, movedBks = 0, movedNotes = 0

const idMapUser = new Map()      // old id → new id
const idMapService = new Map()

// Users: json-server-auth stored bcrypt hashes in `password` field; reuse them.
const insertUser = db.prepare(`
  INSERT OR IGNORE INTO users (id, email, passwordHash, name, displayName, phone, timezone, bio, workingHours)
  VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
`)
for (const u of users) {
  const info = insertUser.run(
    u.id,
    String(u.email).toLowerCase(),
    u.password || '',
    u.name || '—',
    u.displayName ?? null,
    u.phone ?? null,
    u.timezone ?? null,
    u.bio ?? null,
    u.workingHours ? JSON.stringify(u.workingHours) : null,
  )
  // Map even on conflict — id stays the same.
  idMapUser.set(u.id, u.id)
  if (info.changes) movedUsers++
}

const insertService = db.prepare(`
  INSERT OR IGNORE INTO services (id, providerId, tag, tone, duration, price, name, description)
  VALUES (?, ?, ?, ?, ?, ?, ?, ?)
`)
for (const s of services) {
  if (!idMapUser.has(s.providerId)) continue   // orphan
  const info = insertService.run(
    s.id,
    s.providerId,
    JSON.stringify(s.tag || { en: '', ru: '' }),
    s.tone || 'muted',
    s.duration || 60,
    s.price || 0,
    JSON.stringify(s.name || { en: '', ru: '' }),
    JSON.stringify(s.description || { en: '', ru: '' }),
  )
  idMapService.set(s.id, s.id)
  if (info.changes) movedSvcs++
}

const insertBooking = db.prepare(`
  INSERT OR IGNORE INTO bookings (
    id, providerId, customerId, serviceId,
    dateISO, time, endTime, durationMin, service, total, status,
    withName, initials, customerEmail, customerPhone, notes, createdAt
  ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
`)
for (const b of bookings) {
  if (!idMapUser.has(b.providerId) || !idMapUser.has(b.customerId)) continue
  const info = insertBooking.run(
    b.id,
    b.providerId,
    b.customerId,
    b.serviceId ? Number(b.serviceId) : null,
    b.dateISO || '',
    b.time || '',
    b.endTime ?? null,
    b.durationMin || 60,
    b.service || '',
    b.total || 0,
    b.status || 'confirmed',
    b.withName || '',
    b.initials ?? null,
    b.customerEmail ?? null,
    b.customerPhone ?? null,
    b.notes ?? null,
    b.createdAt || new Date().toISOString(),
  )
  if (info.changes) movedBks++
}

const insertNotif = db.prepare(`
  INSERT OR IGNORE INTO notifications (id, userId, kind, tone, createdAt, unread, params)
  VALUES (?, ?, ?, ?, ?, ?, ?)
`)
for (const n of notifications) {
  if (!idMapUser.has(n.userId)) continue
  const info = insertNotif.run(
    n.id,
    n.userId,
    n.kind || 'check',
    n.tone || null,
    n.createdAt || new Date().toISOString(),
    n.unread ? 1 : 0,
    n.params ? JSON.stringify(n.params) : null,
  )
  if (info.changes) movedNotes++
}

console.log(`✓ Migration complete:`)
console.log(`  users:         +${movedUsers}`)
console.log(`  services:      +${movedSvcs}`)
console.log(`  bookings:      +${movedBks}`)
console.log(`  notifications: +${movedNotes}`)
console.log(`  → slottr.db`)
