import {
  DEFAULT_WORKING_HOURS,
  calculateSlots,
  dowKeyFromISO,
  hhmmToMin,
  normalizeWorkingHours,
} from '../availability.mjs'
import { MIN_NOTICE_MIN } from '../config.mjs'
import { dbAll, dbGet } from '../db.mjs'
import { requireAuth } from '../middleware/authMiddleware.mjs'
import { asyncRoute } from '../middleware/asyncRoute.mjs'

export function registerAvailabilityRoutes(app) {
  app.get(
    '/availability/:providerId',
    requireAuth,
    asyncRoute(async (req, res) => {
      const providerId = Number(req.params.providerId)
      const dateISO = String(req.query.date || '')
      const duration = Number(req.query.duration) || 60

      if (!/^\d{4}-\d{2}-\d{2}$/.test(dateISO)) {
        return res.status(400).json({ error: 'date query param required as YYYY-MM-DD' })
      }
      const provider = await dbGet('SELECT * FROM users WHERE id = ?', [providerId])
      if (!provider) return res.status(404).json({ error: 'Provider not found' })

      const workingHours = normalizeWorkingHours(
        provider.workingHours ? JSON.parse(provider.workingHours) : undefined,
      )
      const dayKey = dowKeyFromISO(dateISO)
      const hasOwn = Object.prototype.hasOwnProperty.call(workingHours, dayKey)
      const window = hasOwn ? workingHours[dayKey] : DEFAULT_WORKING_HOURS[dayKey] || null
      if (!window) return res.json({ slots: [], workingHours: null })

      const blockingRows = await dbAll(
        `
      SELECT time, endTime, durationMin FROM bookings
      WHERE providerId = ? AND dateISO = ? AND status != 'cancelled'
    `,
        [providerId, dateISO],
      )
      const blocking = blockingRows.map((row) => {
        const start = hhmmToMin(row.time)
        const end = row.endTime ? hhmmToMin(row.endTime) : start + (Number(row.durationMin) || 60)
        return [start, end]
      })

      const slots = calculateSlots({
        window,
        blocking,
        now: new Date(),
        dateISO,
        duration,
        minNoticeMin: MIN_NOTICE_MIN,
      })
      res.json({ slots, workingHours: window })
    }),
  )
}
