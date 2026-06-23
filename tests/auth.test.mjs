// Unit tests for scripts/auth.mjs — JWT sign/verify + refresh-token hashing.
// These run with no DB, no Express, no network.

import { describe, it, expect } from 'vitest'
import jwt from 'jsonwebtoken'
import { signAccessToken, hashRefresh, parseToken } from '../scripts/auth.mjs'

const SECRET = 'test-secret-not-used-anywhere-else'

describe('signAccessToken', () => {
  it('produces a verifiable JWT carrying the user id as sub', () => {
    const token = signAccessToken({ id: 42, email: 'a@b.co' }, SECRET)
    const decoded = jwt.verify(token, SECRET)
    expect(decoded.sub).toBe('42')
    expect(decoded.email).toBe('a@b.co')
  })

  it('honours a custom expiresIn', () => {
    const token = signAccessToken({ id: 1, email: 'x@y.co' }, SECRET, '5s')
    const decoded = jwt.verify(token, SECRET)
    expect(decoded.exp - decoded.iat).toBeGreaterThanOrEqual(4)
    expect(decoded.exp - decoded.iat).toBeLessThanOrEqual(6)
  })

  it('throws when no secret is supplied', () => {
    expect(() => signAccessToken({ id: 1, email: 'x@y.co' }, '')).toThrow(/secret/)
  })

  it('throws when user has no id', () => {
    expect(() => signAccessToken({ email: 'x@y.co' }, SECRET)).toThrow(/user\.id/)
  })

  it('uses HS256 algorithm', () => {
    const token = signAccessToken({ id: 1, email: 'x@y.co' }, SECRET)
    expect(jwt.decode(token, { complete: true }).header.alg).toBe('HS256')
  })
})

describe('hashRefresh', () => {
  it('is deterministic — same input gives the same hex digest', () => {
    const a = hashRefresh('the-quick-brown-fox')
    const b = hashRefresh('the-quick-brown-fox')
    expect(a).toBe(b)
    expect(a).toMatch(/^[0-9a-f]{64}$/)
  })

  it('produces different digests for different inputs', () => {
    expect(hashRefresh('token-a')).not.toBe(hashRefresh('token-b'))
  })

  it('throws on empty / non-string input', () => {
    expect(() => hashRefresh('')).toThrow()
    expect(() => hashRefresh(null)).toThrow()
    expect(() => hashRefresh(123)).toThrow()
  })
})

describe('parseToken', () => {
  const user = { id: 7, email: 'u@u.co' }

  it('returns null without a secret (defensive default)', () => {
    const token = signAccessToken(user, SECRET)
    expect(parseToken(`Bearer ${token}`, '')).toBeNull()
  })

  it('returns null when Authorization header is missing', () => {
    expect(parseToken(undefined, SECRET)).toBeNull()
    expect(parseToken('', SECRET)).toBeNull()
  })

  it('returns null when scheme is not Bearer', () => {
    const token = signAccessToken(user, SECRET)
    expect(parseToken(`Basic ${token}`, SECRET)).toBeNull()
  })

  it('returns null for a malformed token', () => {
    expect(parseToken('Bearer not-a-jwt', SECRET)).toBeNull()
  })

  it('returns null when the signature is wrong', () => {
    const token = signAccessToken(user, SECRET)
    expect(parseToken(`Bearer ${token}`, 'a-different-secret')).toBeNull()
  })

  it('returns null for an expired token', () => {
    const token = signAccessToken(user, SECRET, '-1s')
    expect(parseToken(`Bearer ${token}`, SECRET)).toBeNull()
  })

  it('returns null for a token without a sub claim', () => {
    const bogus = jwt.sign({ email: 'x@y.co' }, SECRET, { algorithm: 'HS256' })
    expect(parseToken(`Bearer ${bogus}`, SECRET)).toBeNull()
  })

  it('round-trips a freshly signed token', () => {
    const token = signAccessToken(user, SECRET)
    const result = parseToken(`Bearer ${token}`, SECRET)
    expect(result).toEqual({ userId: 7, email: 'u@u.co' })
  })
})
