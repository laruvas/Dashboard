// libSQL (Turso) client for Slottr.
//
// Same API works with:
// - local file (dev): url='file:./slottr.db'
// - remote Turso (prod): url='libsql://...' + authToken
// - in-memory (tests): url='file::memory:' via LIBSQL_URL
//
// Schema is created on first connect. JSON-typed columns (workingHours,
// params, tag, name, description) store stringified JSON — parsed on read
// in the row→API mappers below.

import { createClient } from '@libsql/client'
import { dirname, resolve } from 'node:path'
import { fileURLToPath } from 'node:url'

const __dirname = dirname(fileURLToPath(import.meta.url))

// In dev we use a local file. In prod (Render) set TURSO_DATABASE_URL +
// TURSO_AUTH_TOKEN to point at a managed Turso database.
//
// LIBSQL_URL is an undocumented escape hatch used by the test suite so it
// can spin up an in-memory database without touching the real slottr.db.
const url =
  process.env.LIBSQL_URL ||
  process.env.TURSO_DATABASE_URL ||
  `file:${resolve(__dirname, '..', 'slottr.db')}`
const authToken = process.env.TURSO_AUTH_TOKEN

export const db = createClient({ url, authToken })

/* ============== Schema ============== */

async function migrate() {
  const statements = [
    `CREATE TABLE IF NOT EXISTS users (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      email TEXT NOT NULL UNIQUE COLLATE NOCASE,
      passwordHash TEXT NOT NULL,
      name TEXT NOT NULL,
      displayName TEXT,
      phone TEXT,
      timezone TEXT,
      bio TEXT,
      workingHours TEXT,
      createdAt TEXT NOT NULL DEFAULT (datetime('now'))
    )`,
    `CREATE TABLE IF NOT EXISTS services (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      providerId INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
      tag TEXT NOT NULL,
      tone TEXT NOT NULL,
      duration INTEGER NOT NULL,
      price REAL NOT NULL,
      name TEXT NOT NULL,
      description TEXT NOT NULL,
      createdAt TEXT NOT NULL DEFAULT (datetime('now'))
    )`,
    `CREATE INDEX IF NOT EXISTS idx_services_provider ON services(providerId)`,
    `CREATE TABLE IF NOT EXISTS bookings (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      providerId INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
      customerId INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
      serviceId INTEGER REFERENCES services(id) ON DELETE SET NULL,
      dateISO TEXT NOT NULL,
      time TEXT NOT NULL,
      endTime TEXT,
      durationMin INTEGER NOT NULL,
      service TEXT NOT NULL,
      total REAL NOT NULL,
      status TEXT NOT NULL,
      withName TEXT NOT NULL,
      initials TEXT,
      customerEmail TEXT,
      customerPhone TEXT,
      notes TEXT,
      createdAt TEXT NOT NULL DEFAULT (datetime('now'))
    )`,
    `CREATE INDEX IF NOT EXISTS idx_bookings_provider ON bookings(providerId)`,
    `CREATE INDEX IF NOT EXISTS idx_bookings_customer ON bookings(customerId)`,
    `CREATE INDEX IF NOT EXISTS idx_bookings_date ON bookings(dateISO)`,
    `CREATE TABLE IF NOT EXISTS notifications (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      userId INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
      kind TEXT NOT NULL,
      tone TEXT,
      createdAt TEXT NOT NULL DEFAULT (datetime('now')),
      unread INTEGER NOT NULL DEFAULT 1,
      params TEXT
    )`,
    `CREATE INDEX IF NOT EXISTS idx_notifications_user ON notifications(userId)`,
    `CREATE TABLE IF NOT EXISTS refresh_tokens (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      userId INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
      tokenHash TEXT NOT NULL UNIQUE,
      expiresAt TEXT NOT NULL,
      createdAt TEXT NOT NULL DEFAULT (datetime('now'))
    )`,
    `CREATE INDEX IF NOT EXISTS idx_refresh_user ON refresh_tokens(userId)`,
    `CREATE INDEX IF NOT EXISTS idx_refresh_hash ON refresh_tokens(tokenHash)`,
  ]
  for (const sql of statements) await db.execute(sql)
}
await migrate()

const parseJSON = (s, fallback) => {
  if (s == null) return fallback
  try {
    return JSON.parse(s)
  } catch {
    return fallback
  }
}

export function rowToUser(row) {
  if (!row) return null
  return {
    id: Number(row.id),
    email: row.email,
    name: row.name,
    displayName: row.displayName ?? undefined,
    phone: row.phone ?? undefined,
    timezone: row.timezone ?? undefined,
    bio: row.bio ?? undefined,
    workingHours: parseJSON(row.workingHours, undefined),
  }
}

export function rowToService(row) {
  if (!row) return null
  return {
    id: Number(row.id),
    providerId: Number(row.providerId),
    tag: parseJSON(row.tag, { en: '', ru: '' }),
    tone: row.tone,
    duration: Number(row.duration),
    price: Number(row.price),
    name: parseJSON(row.name, { en: '', ru: '' }),
    description: parseJSON(row.description, { en: '', ru: '' }),
  }
}

export function rowToBooking(row) {
  if (!row) return null
  return {
    id: Number(row.id),
    providerId: Number(row.providerId),
    customerId: Number(row.customerId),
    serviceId: row.serviceId == null ? undefined : String(row.serviceId),
    dateISO: row.dateISO,
    time: row.time,
    endTime: row.endTime ?? undefined,
    durationMin: Number(row.durationMin),
    service: row.service,
    total: Number(row.total),
    status: row.status,
    withName: row.withName,
    initials: row.initials ?? '',
    customerEmail: row.customerEmail ?? '',
    customerPhone: row.customerPhone ?? null,
    notes: row.notes ?? null,
    createdAt: row.createdAt,
  }
}

export function rowToNotification(row) {
  if (!row) return null
  return {
    id: Number(row.id),
    userId: Number(row.userId),
    kind: row.kind,
    tone: row.tone ?? undefined,
    createdAt: row.createdAt,
    unread: !!row.unread,
    params: parseJSON(row.params, {}),
  }
}

export async function dbGet(sql, args) {
  const r = await db.execute({ sql, args: args || [] })
  return r.rows[0]
}

export async function dbAll(sql, args) {
  const r = await db.execute({ sql, args: args || [] })
  return r.rows
}

export async function dbRun(sql, args) {
  const r = await db.execute({ sql, args: args || [] })
  return {
    lastInsertRowid: r.lastInsertRowid != null ? Number(r.lastInsertRowid) : null,
    rowsAffected: r.rowsAffected,
  }
}
