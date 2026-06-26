import { hhmmToMin } from '../availability.mjs'
import { dbAll, dbGet, dbRun, rowToBooking, rowToService } from '../db.mjs'
import { requireAuth } from '../middleware/authMiddleware.mjs'
import { asyncRoute } from '../middleware/asyncRoute.mjs'
import { pushNotification } from '../services/notificationService.mjs'

const DATE_RE = /^\d{4}-\d{2}-\d{2}$/
const TIME_RE = /^\d{2}:\d{2}$/

function addMinutesHHMM(time, minutesToAdd) {
  const [hStr, mStr] = String(time).split(':')
  const total = Number(hStr) * 60 + Number(mStr) + minutesToAdd
  return `${String(Math.floor(total / 60) % 24).padStart(2, '0')}:${String(total % 60).padStart(2, '0')}`
}

function serviceDisplayName(serviceRow) {
  const service = rowToService(serviceRow)
  return service.name?.en || service.name?.ru || 'Service'
}

function intervalsOverlap(startA, endA, startB, endB) {
  return startA < endB && startB < endA
}

async function hasBookingConflict({
  providerId,
  dateISO,
  startMin,
  endMin,
  excludeBookingId = null,
}) {
  const args = [providerId, dateISO]
  let excludeSql = ''

  if (excludeBookingId != null) {
    excludeSql = 'AND id != ?'
    args.push(excludeBookingId)
  }

  const rows = await dbAll(
    `
    SELECT id, time, endTime, durationMin FROM bookings
    WHERE providerId = ? AND dateISO = ? AND status != 'cancelled'
    ${excludeSql}
  `,
    args,
  )

  return rows.some((booking) => {
    const bookingStart = hhmmToMin(booking.time)
    const bookingEnd = booking.endTime
      ? hhmmToMin(booking.endTime)
      : bookingStart + (Number(booking.durationMin) || 60)
    return intervalsOverlap(startMin, endMin, bookingStart, bookingEnd)
  })
}

function validateDateTime(dateISO, time) {
  if (!DATE_RE.test(String(dateISO || ''))) return 'dateISO required as YYYY-MM-DD'
  if (!TIME_RE.test(String(time || ''))) return 'time required as HH:MM'
  const startMin = hhmmToMin(time)
  if (!Number.isFinite(startMin)) return 'time required as HH:MM'
  return null
}

export function registerBookingRoutes(app) {
  app.get(
    '/bookings',
    requireAuth,
    asyncRoute(async (req, res) => {
      const me = req.user.userId
      const rows = await dbAll(
        `
      SELECT * FROM bookings WHERE providerId = ? OR customerId = ? ORDER BY dateISO, time
    `,
        [me, me],
      )
      res.json(rows.map(rowToBooking))
    }),
  )

  app.get(
    '/bookings/:id',
    requireAuth,
    asyncRoute(async (req, res) => {
      const row = await dbGet('SELECT * FROM bookings WHERE id = ?', [Number(req.params.id)])
      if (!row) return res.status(404).json({ error: 'Booking not found' })
      const me = req.user.userId
      if (Number(row.providerId) !== me && Number(row.customerId) !== me) {
        return res.status(403).json({ error: 'Forbidden' })
      }
      res.json(rowToBooking(row))
    }),
  )

  app.post(
    '/bookings',
    requireAuth,
    asyncRoute(async (req, res) => {
      const booking = req.body || {}
      const serviceId = Number(booking.serviceId)
      if (!serviceId) return res.status(400).json({ error: 'serviceId required' })

      const service = await dbGet('SELECT * FROM services WHERE id = ?', [serviceId])
      if (!service) return res.status(400).json({ error: 'Unknown serviceId' })
      if (Number(service.providerId) !== req.user.userId) {
        return res.status(403).json({ error: "Cannot book another user's service" })
      }

      const dateISO = String(booking.dateISO || '')
      const time = String(booking.time || '')
      const dateTimeError = validateDateTime(dateISO, time)
      if (dateTimeError) return res.status(400).json({ error: dateTimeError })

      const durationMin = Number(service.duration) || 60
      const startMin = hhmmToMin(time)
      const endMin = startMin + durationMin
      const conflict = await hasBookingConflict({
        providerId: Number(service.providerId),
        dateISO,
        startMin,
        endMin,
      })
      if (conflict) return res.status(409).json({ error: 'Selected time slot is already booked' })

      const info = await dbRun(
        `
      INSERT INTO bookings (
        providerId, customerId, serviceId,
        dateISO, time, endTime, durationMin, service, total, status,
        withName, initials, customerEmail, customerPhone, notes
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    `,
        [
          Number(service.providerId),
          req.user.userId,
          serviceId,
          dateISO,
          time,
          addMinutesHHMM(time, durationMin),
          durationMin,
          serviceDisplayName(service),
          Number(service.price) || 0,
          'confirmed',
          String(booking.withName || ''),
          String(booking.initials || ''),
          String(booking.customerEmail || ''),
          booking.customerPhone || null,
          booking.notes || null,
        ],
      )
      const row = await dbGet('SELECT * FROM bookings WHERE id = ?', [info.lastInsertRowid])
      await pushNotification(
        req.user.userId,
        'calendar',
        {
          bookingId: row.id,
          service: row.service,
          withName: row.withName,
          dateISO: row.dateISO,
          time: row.time,
        },
        'accent',
      )
      res.status(201).json(rowToBooking(row))
    }),
  )

  app.patch(
    '/bookings/:id',
    requireAuth,
    asyncRoute(async (req, res) => {
      const id = Number(req.params.id)
      const existing = await dbGet('SELECT * FROM bookings WHERE id = ?', [id])
      if (!existing) return res.status(404).json({ error: 'Booking not found' })
      if (Number(existing.providerId) !== req.user.userId) {
        return res.status(403).json({ error: 'Only the provider can modify this booking' })
      }

      const nextDateISO =
        'dateISO' in (req.body || {}) ? String(req.body.dateISO || '') : existing.dateISO
      const nextTime = 'time' in (req.body || {}) ? String(req.body.time || '') : existing.time
      const nextDuration = Number(existing.durationMin) || 60
      const isReschedule = nextDateISO !== existing.dateISO || nextTime !== existing.time

      if (isReschedule) {
        const dateTimeError = validateDateTime(nextDateISO, nextTime)
        if (dateTimeError) return res.status(400).json({ error: dateTimeError })
        const startMin = hhmmToMin(nextTime)
        const endMin = startMin + nextDuration
        const conflict = await hasBookingConflict({
          providerId: Number(existing.providerId),
          dateISO: nextDateISO,
          startMin,
          endMin,
          excludeBookingId: id,
        })
        if (conflict) return res.status(409).json({ error: 'Selected time slot is already booked' })
        req.body.endTime = addMinutesHHMM(nextTime, nextDuration)
      }

      const allowed = [
        'dateISO',
        'time',
        'endTime',
        'durationMin',
        'status',
        'withName',
        'initials',
        'customerEmail',
        'customerPhone',
        'notes',
        'service',
        'total',
      ]
      const sets = []
      const values = []
      for (const key of allowed) {
        if (!(key in (req.body || {}))) continue
        sets.push(`${key} = ?`)
        values.push(req.body[key])
      }
      if (sets.length) {
        values.push(id)
        await dbRun(`UPDATE bookings SET ${sets.join(', ')} WHERE id = ?`, values)
      }
      const updated = await dbGet('SELECT * FROM bookings WHERE id = ?', [id])

      if (updated.status === 'cancelled' && existing.status !== 'cancelled') {
        await pushNotification(
          req.user.userId,
          'close',
          {
            bookingId: updated.id,
            service: updated.service,
            withName: updated.withName,
            dateISO: updated.dateISO,
            time: updated.time,
          },
          'danger',
        )
      } else if (updated.time !== existing.time || updated.dateISO !== existing.dateISO) {
        await pushNotification(
          req.user.userId,
          'clock',
          {
            bookingId: updated.id,
            service: updated.service,
            withName: updated.withName,
            oldDateISO: existing.dateISO,
            oldTime: existing.time,
            newDateISO: updated.dateISO,
            newTime: updated.time,
            dateISO: updated.dateISO,
            time: updated.time,
          },
          'accent',
        )
      }
      res.json(rowToBooking(updated))
    }),
  )

  app.delete(
    '/bookings/:id',
    requireAuth,
    asyncRoute(async (req, res) => {
      const id = Number(req.params.id)
      const existing = await dbGet('SELECT * FROM bookings WHERE id = ?', [id])
      if (!existing) return res.status(404).json({ error: 'Booking not found' })
      if (Number(existing.providerId) !== req.user.userId) {
        return res.status(403).json({ error: 'Only the provider can delete this booking' })
      }
      await dbRun('DELETE FROM bookings WHERE id = ?', [id])
      res.status(204).end()
    }),
  )
}
