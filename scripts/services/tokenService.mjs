import { randomBytes } from 'node:crypto'
import { signAccessToken, hashRefresh } from '../auth.mjs'
import { dbGet, dbRun, rowToUser } from '../db.mjs'
import { JWT_SECRET, JWT_EXPIRES_IN, REFRESH_TTL_MS } from '../config.mjs'

export function issueAccessToken(user) {
  return signAccessToken(user, JWT_SECRET, JWT_EXPIRES_IN)
}

export async function issueRefreshToken(userId) {
  const plain = randomBytes(48).toString('base64url')
  const tokenHash = hashRefresh(plain)
  const expiresAt = new Date(Date.now() + REFRESH_TTL_MS).toISOString()
  await dbRun(
    'INSERT INTO refresh_tokens (userId, tokenHash, expiresAt) VALUES (?, ?, ?)',
    [userId, tokenHash, expiresAt],
  )
  return plain
}

export async function consumeRefreshToken(plain) {
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

export async function purgeExpiredRefreshTokens() {
  await dbRun('DELETE FROM refresh_tokens WHERE expiresAt < ?', [new Date().toISOString()])
}
