// Custom Express server — libSQL (Turso / local file) + JWT with refresh rotation.
//
// Endpoints are registered from ./routes/* so this file stays focused on
// application wiring: middleware, route registration, error handling and boot.

import express from 'express'
import cors from 'cors'
import { fileURLToPath } from 'node:url'
import { CORS_ORIGINS, HAS_CONFIGURED_JWT_SECRET, JWT_EXPIRES_IN, PORT } from './config.mjs'
import { registerAuthRoutes } from './routes/authRoutes.mjs'
import { registerUserRoutes } from './routes/userRoutes.mjs'
import { registerServiceRoutes, validateServicePayload } from './routes/serviceRoutes.mjs'
import { registerBookingRoutes } from './routes/bookingRoutes.mjs'
import { registerAvailabilityRoutes } from './routes/availabilityRoutes.mjs'
import { registerNotificationRoutes } from './routes/notificationRoutes.mjs'
import { purgeExpiredRefreshTokens } from './services/tokenService.mjs'

export { validateServicePayload }

export const app = express()

app.use(
  cors({
    origin: CORS_ORIGINS.includes('*') ? true : CORS_ORIGINS,
    credentials: false,
  }),
)
app.use(express.json())

app.get('/healthz', (_req, res) => res.json({ ok: true }))

registerAuthRoutes(app)
registerUserRoutes(app)
registerServiceRoutes(app)
registerBookingRoutes(app)
registerAvailabilityRoutes(app)
registerNotificationRoutes(app)

purgeExpiredRefreshTokens().catch(() => {
  /* ignore startup error */
})
setInterval(
  () => {
    purgeExpiredRefreshTokens().catch(() => {})
  },
  24 * 60 * 60 * 1000,
).unref()

app.use((err, req, res, _next) => {
  console.error('[error]', err)
  res.status(500).json({ error: 'Internal server error' })
})

export function startServer(port = PORT) {
  const dbInfo = process.env.TURSO_DATABASE_URL ? 'Turso (remote)' : 'local file ./slottr.db'
  console.log(` {^_^}/ Slottr API on port ${port}`)
  console.log(` DB: ${dbInfo}`)
  console.log(` CORS: ${CORS_ORIGINS.join(', ')}`)
  console.log(
    ` JWT: HS256, exp ${JWT_EXPIRES_IN}${HAS_CONFIGURED_JWT_SECRET ? '' : ' (dev secret — set JWT_SECRET in prod!)'}`,
  )
  return app.listen(port)
}

const isMain = process.argv[1] && process.argv[1] === fileURLToPath(import.meta.url)
if (isMain) startServer()
