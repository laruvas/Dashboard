export const PORT = Number(process.env.PORT || 3001)

if (!process.env.JWT_SECRET && process.env.NODE_ENV === 'production') {
  throw new Error('JWT_SECRET is required in production')
}

export const JWT_SECRET = process.env.JWT_SECRET || 'dev-secret-key'
export const HAS_CONFIGURED_JWT_SECRET = Boolean(process.env.JWT_SECRET)
export const JWT_EXPIRES_IN = '15m'
export const REFRESH_TTL_DAYS = 30
export const REFRESH_TTL_MS = REFRESH_TTL_DAYS * 24 * 60 * 60 * 1000
export const BCRYPT_ROUNDS = 10
export const MIN_NOTICE_MIN = 60

export const CORS_ORIGINS = (process.env.CORS_ORIGIN || '*')
  .split(',')
  .map((s) => s.trim())
  .filter(Boolean)
