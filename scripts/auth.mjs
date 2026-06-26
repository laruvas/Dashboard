// JWT helpers — pure functions, no Express, no DB.
// Kept intentionally tiny so unit tests don't need to spin up the server.
//
// Why parameterise the secret: tests must not depend on process.env.
// server.mjs passes its JWT_SECRET at the call site.

import jwt from 'jsonwebtoken'
import { createHash } from 'node:crypto'

export const DEFAULT_ACCESS_EXPIRES_IN = '15m'

/** Sign a short-lived access token for a user. */
export function signAccessToken(user, secret, expiresIn = DEFAULT_ACCESS_EXPIRES_IN) {
  if (!secret) throw new Error('signAccessToken: secret is required')
  if (!user || user.id == null) throw new Error('signAccessToken: user.id is required')
  return jwt.sign({ sub: String(user.id), email: user.email }, secret, {
    expiresIn,
    algorithm: 'HS256',
  })
}

/** SHA-256 hex digest of a refresh token. We store only the hash, never the plain text. */
export function hashRefresh(plain) {
  if (typeof plain !== 'string' || !plain) {
    throw new Error('hashRefresh: non-empty string required')
  }
  return createHash('sha256').update(plain).digest('hex')
}

/**
 * Verify an `Authorization: Bearer <token>` header.
 * Returns `{ userId, email }` on success, `null` on any failure
 * (missing header, wrong scheme, bad signature, expired, malformed payload).
 */
export function parseToken(authHeader, secret) {
  if (!secret) return null
  const header = authHeader || ''
  const match = header.match(/^Bearer\s+(.+)$/)
  if (!match) return null
  try {
    const decoded = jwt.verify(match[1], secret, { algorithms: ['HS256'] })
    if (!decoded || typeof decoded === 'string') return null
    if (decoded.sub == null) return null
    return { userId: Number(decoded.sub), email: decoded.email }
  } catch {
    return null
  }
}
