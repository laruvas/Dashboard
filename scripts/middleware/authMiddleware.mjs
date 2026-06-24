import { parseToken } from '../auth.mjs'
import { JWT_SECRET } from '../config.mjs'

export function parseAuthHeader(req) {
  return parseToken(req.headers.authorization || '', JWT_SECRET)
}

export function requireAuth(req, res, next) {
  const user = parseAuthHeader(req)
  if (!user) return res.status(401).json({ error: 'Authentication required' })
  req.user = user
  next()
}
