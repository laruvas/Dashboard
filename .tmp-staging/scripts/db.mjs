// SQLite layer for Slottr. One file (slottr.db), one connection, prepared
// statements exported below. Schema is created on first open via `migrate()`.
//
// JSON-typed columns (workingHours, params, tag, name, description) store
// stringified JSON — we parse on read in toRow* helpers.

import Database from 'better-sqlite3'
import { dirname, resolve } from 'node:path'
import { fileURLToPath, URL } from 'node:url'

const __dirname = dirname(fileURLToPath(import.meta.url))
export const DB_FILE = resolve(__dirname, '..', 'slottr.db')

export const db = new Database(DB_FILE)
db.pragma('journal_mode = WAL')
db.pragma('foreign_keys = ON')

/* ============== Schema ============== */

function migrate() {
  db.exec(`
    CREATE TABLE IF NOT EXISTS users (
      id            INTEGER PRIMARY KEY AUTOINCREMENT,
      email         TEXT NOT NULL UNIQUE COLLATE NOCASE,
      passwordHash  TEXT NOT NULL,
      name          TEXT NOT NULL,
      displayName   TEXT,
      phone         TEXT,
      timezone      TEXT,
      bio           TEXT,
      workingHours  TEXT,                              -- JSON
      createdAt     TEXT NOT NULL DEFAULT (datetime('now'))
    );

    CREATE TABLE IF NOT EXISTS services (
      id           INTEGER PRIMARY KEY AUTOINCREMENT,
      providerId   INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
      tag          TEXT NOT NULL,                      -- JSON {en, ru}
      tone         TEXT NOT NULL,
      duration     INTEGER NOT NULL,
      price        REAL NOT NULL,
      name         TEXT NOT NULL,                      -- JSON {en, ru}
      description  TEXT NOT NULL,                      -- JSON {en, ru}
      createdAt    TEXT NOT NULL DEFAULT (datetime('now'))
    );
    CREATE INDEX IF NOT EXISTS idx_services_provider ON services(providerId);

    CREATE TABLE IF NOT EXISTS bookings (
      id             INTEGER PRIMARY KEY AUTOINCREMENT,
      providerId     INTEGER NOT NULL REFERENCES users(id)    ON DELETE CASCADE,
      customerId     INTEGER NOT NULL REFERENCES users(id)    ON DELETE CASCADE,
      serviceId      INTEGER          REFERENCES services(id) ON DELETE SET NULL,
      dateISO        TEXT NOT NULL,
      time           TEXT NOT NULL,
      endTime        TEXT,
      durationMin    INTEGER NOT NULL,
      service        TEXT NOT NULL,                   -- snapshot of service name
      total          REAL NOT NULL,
      status         TEXT NOT NULL,
      withName       TEXT NOT NULL,
      initials       TEXT,
      customerEmail  TEXT,
      customerPhone  TEXT,
      notes          TEXT,
      createdAt      TEXT NOT NULL DEFAULT (datetime('now'))
    );
    CREATE INDEX IF NOT EXISTS idx_bookings_provider  ON bookings(providerId);
    CREATE INDEX IF NOT EXISTS idx_bookings_customer  ON bookings(customerId);
    CREATE INDEX IF NOT EXISTS idx_bookings_date      ON bookings(dateISO);

    CREATE TABLE IF NOT EXISTS notifications (
      id         INTEGER PRIMARY KEY AUTOINCREMENT,
      userId     INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
      kind       TEXT NOT NULL,
      tone       TEXT,
      createdAt  TEXT NOT NULL DEFAULT (datetime('now')),
      unread     INTEGER NOT NULL DEFAULT 1,
      params     TEXT                                  -- JSON
    );
    CREATE INDEX IF NOT EXISTS idx_notifications_user ON notifications(userId);

    CREATE TABLE IF NOT EXISTS refresh_tokens (
      id         INTEGER PRIMARY KEY AUTOINCREMENT,
      userId     INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
      tokenHash  TEXT NOT NULL UNIQUE,                -- sha256 of the random token
      expiresAt  TEXT NOT NULL,                       -- ISO timestamp
      createdAt  TEXT NOT NULL DEFAULT (datetime('now'))
    );
    CREATE INDEX IF NOT EXISTS idx_refresh_user ON refresh_tokens(userId);
    CREATE INDEX IF NOT EXISTS idx_refresh_hash ON refresh_tokens(tokenHash);
  `)
}
migrate()

/* ============== Row → API shape helpers ============== */

const parseJSON = (s, fallback) => {
  if (s == null) return fallback
  try { return JSON.parse(s) } catch { return fallback }
}

/** Strip passwordHash before sending the user to the client. */
export function rowToUser(row) {
  if (!row) return null
  return {
    id:           row.id,
    email:        row.email,
    name:         row.name,
    displayName:  row.displayName  ?? undefined,
    phone:        row.phone        ?? undefined,
    timezone:     row.timezone     ?? undefined,
    bio:          row.bio          ?? undefined,
    workingHours: parseJSON(row.workingHours, undefined),
  }
}

export function rowToService(row) {
  if (!row) return null
  return {
    id:          row.id,
    providerId:  row.providerId,
    tag:         parseJSON(row.tag, { en: '', ru: '' }),
    tone:        row.tone,
    duration:    row.duration,
    price:       row.price,
    name:        parseJSON(row.name, { en: '', ru: '' }),
    description: parseJSON(row.description, { en: '', ru: '' }),
  }
}

export function rowToBooking(row) {
  if (!row) return null
  return {
    id:            row.id,
    providerId:    row.providerId,
    customerId:    row.customerId,
    serviceId:     row.serviceId == null ? undefined : String(row.serviceId),
    dateISO:       row.dateISO,
    time:          row.time,
    endTime:       row.endTime ?? undefined,
    durationMin:   row.durationMin,
    service:       row.service,
    total:         row.total,
    status:        row.status,
    withName:      row.withName,
    initials:      row.initials ?? '',
    customerEmail: row.customerEmail ?? '',
    customerPhone: row.customerPhone ?? null,
    notes:         row.notes         ?? null,
    createdAt:     row.createdAt,
  }
}

export function rowToNotification(row) {
  if (!row) return null
  return {
    id:        row.id,
    userId:    row.userId,
    kind:      row.kind,
    tone:      row.tone ?? undefined,
    createdAt: row.createdAt,
    unread:    !!row.unread,
    params:    parseJSON(row.params, {}),
  }
}
