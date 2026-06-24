import { dbAll, dbGet, dbRun, rowToBooking } from '../db.mjs'
import { requireAuth } from '../middleware/authMiddleware.mjs'
import { asyncRoute } from '../middleware/asyncRoute.mjs'
import { pushNotification } from '../services/notificationService.mjs'

export function registerBookingRoutes(app) {
  app.get('/bookings', requireAuth, asyncRoute(async (req, res) => {
    const me = req.user.userId
    const rows = await dbAll(`
      SELECT * FROM bookings WHERE providerId = ? OR customerId = ? ORDER BY dateISO, time
    `, [me, me])
    res.json(rows.map(rowToBooking))
  }))

  app.get('/bookings/:id', requireAuth, asyncRoute(async (req, res) => {
    const row = await dbGet('SELECT * FROM bookings WHERE id = ?', [Number(req.params.id)])
    if (!row) return res.status(404).json({ error: 'Booking not found' })
    const me = req.user.userId
    if (Number(row.providerId) !== me && Number(row.customerId) !== me) {
      return res.status(403).json({ error: 'Forbidden' })
    }
    res.json(rowToBooking(row))
  }))

  app.post('/bookings', requireAuth, asyncRoute(async (req, res) => {
    const booking = req.body || {}
    const serviceId = Number(booking.serviceId)
    if (!serviceId) return res.status(400).json({ error: 'serviceId required' })

    const service = await dbGet('SELECT * FROM services WHERE id = ?', [serviceId])
    if (!service) return res.status(400).json({ error: 'Unknown serviceId' })
    if (Number(service.providerId) !== req.user.userId) {
      return res.status(403).json({ error: "Cannot book another user's service" })
    }

    const info = await dbRun(`
      INSERT INTO bookings (
        providerId, customerId, serviceId,
        dateISO, time, endTime, durationMin, service, total, status,
        withName, initials, customerEmail, customerPhone, notes
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    `, [
      Number(service.providerId), req.user.userId, serviceId,
      String(booking.dateISO || ''), String(booking.time || ''), booking.endTime || null,
      Number(booking.durationMin) || 60, String(booking.service || ''), Number(booking.total) || 0,
      String(booking.status || 'confirmed'), String(booking.withName || ''), String(booking.initials || ''),
      String(booking.customerEmail || ''), booking.customerPhone || null, booking.notes || null,
    ])
    const row = await dbGet('SELECT * FROM bookings WHERE id = ?', [info.lastInsertRowid])
    await pushNotification(req.user.userId, 'calendar', {
      service: row.service, withName: row.withName, dateISO: row.dateISO, time: row.time,
    }, 'accent')
    res.status(201).json(rowToBooking(row))
  }))

  app.patch('/bookings/:id', requireAuth, asyncRoute(async (req, res) => {
    const id = Number(req.params.id)
    const existing = await dbGet('SELECT * FROM bookings WHERE id = ?', [id])
    if (!existing) return res.status(404).json({ error: 'Booking not found' })
    if (Number(existing.providerId) !== req.user.userId) {
      return res.status(403).json({ error: 'Only the provider can modify this booking' })
    }

    const allowed = ['dateISO', 'time', 'endTime', 'durationMin', 'status',
      'withName', 'initials', 'customerEmail', 'customerPhone', 'notes', 'service', 'total']
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
      await pushNotification(req.user.userId, 'close', {
        service: updated.service, dateISO: updated.dateISO, time: updated.time,
      }, 'danger')
    } else if (updated.time !== existing.time || updated.dateISO !== existing.dateISO) {
      await pushNotification(req.user.userId, 'clock', {
        service: updated.service, dateISO: updated.dateISO, time: updated.time,
      }, 'accent')
    }
    res.json(rowToBooking(updated))
  }))

  app.delete('/bookings/:id', requireAuth, asyncRoute(async (req, res) => {
    const id = Number(req.params.id)
    const existing = await dbGet('SELECT * FROM bookings WHERE id = ?', [id])
    if (!existing) return res.status(404).json({ error: 'Booking not found' })
    if (Number(existing.providerId) !== req.user.userId) {
      return res.status(403).json({ error: 'Only the provider can delete this booking' })
    }
    await dbRun('DELETE FROM bookings WHERE id = ?', [id])
    res.status(204).end()
  }))
}
