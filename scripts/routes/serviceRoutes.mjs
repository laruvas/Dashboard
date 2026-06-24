import { dbAll, dbGet, dbRun, rowToService } from '../db.mjs'
import { requireAuth } from '../middleware/authMiddleware.mjs'
import { asyncRoute } from '../middleware/asyncRoute.mjs'

export function validateServicePayload(body) {
  const errs = []
  if (!body || typeof body !== 'object') return ['payload required']
  if (!body.tag || typeof body.tag !== 'object') errs.push('tag required')
  if (!body.name || typeof body.name !== 'object') errs.push('name required')
  if (!body.description || typeof body.description !== 'object') errs.push('description required')
  if (!Number.isFinite(Number(body.duration)) || Number(body.duration) <= 0) errs.push('duration must be > 0')
  if (!Number.isFinite(Number(body.price)) || Number(body.price) < 0) errs.push('price must be >= 0')
  return errs
}

export function registerServiceRoutes(app) {
  app.get('/services', requireAuth, asyncRoute(async (req, res) => {
    const rows = await dbAll('SELECT * FROM services WHERE providerId = ? ORDER BY id', [req.user.userId])
    res.json(rows.map(rowToService))
  }))

  app.get('/services/:id', requireAuth, asyncRoute(async (req, res) => {
    const row = await dbGet('SELECT * FROM services WHERE id = ?', [Number(req.params.id)])
    if (!row) return res.status(404).json({ error: 'Service not found' })
    if (Number(row.providerId) !== req.user.userId) return res.status(403).json({ error: 'Not the owner' })
    res.json(rowToService(row))
  }))

  app.post('/services', requireAuth, asyncRoute(async (req, res) => {
    const errs = validateServicePayload(req.body)
    if (errs.length) return res.status(400).json({ error: errs.join('; ') })
    const info = await dbRun(`
      INSERT INTO services (providerId, tag, tone, duration, price, name, description)
      VALUES (?, ?, ?, ?, ?, ?, ?)
    `, [
      req.user.userId,
      JSON.stringify(req.body.tag),
      String(req.body.tone || 'muted'),
      Number(req.body.duration),
      Number(req.body.price),
      JSON.stringify(req.body.name),
      JSON.stringify(req.body.description),
    ])
    const row = await dbGet('SELECT * FROM services WHERE id = ?', [info.lastInsertRowid])
    res.status(201).json(rowToService(row))
  }))

  app.patch('/services/:id', requireAuth, asyncRoute(async (req, res) => {
    const id = Number(req.params.id)
    const existing = await dbGet('SELECT * FROM services WHERE id = ?', [id])
    if (!existing) return res.status(404).json({ error: 'Service not found' })
    if (Number(existing.providerId) !== req.user.userId) return res.status(403).json({ error: 'Not the owner' })

    const allowed = ['tag', 'tone', 'duration', 'price', 'name', 'description']
    const sets = []
    const values = []
    for (const key of allowed) {
      if (!(key in (req.body || {}))) continue
      sets.push(`${key} = ?`)
      values.push(['tag', 'name', 'description'].includes(key) ? JSON.stringify(req.body[key]) : req.body[key])
    }
    if (sets.length) {
      values.push(id)
      await dbRun(`UPDATE services SET ${sets.join(', ')} WHERE id = ?`, values)
    }
    const updated = await dbGet('SELECT * FROM services WHERE id = ?', [id])
    res.json(rowToService(updated))
  }))

  app.delete('/services/:id', requireAuth, asyncRoute(async (req, res) => {
    const id = Number(req.params.id)
    const existing = await dbGet('SELECT * FROM services WHERE id = ?', [id])
    if (!existing) return res.status(404).json({ error: 'Service not found' })
    if (Number(existing.providerId) !== req.user.userId) return res.status(403).json({ error: 'Not the owner' })
    await dbRun('DELETE FROM services WHERE id = ?', [id])
    res.status(204).end()
  }))
}
