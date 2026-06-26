import { dbGet, dbRun, rowToUser } from '../db.mjs'
import { requireAuth } from '../middleware/authMiddleware.mjs'
import { asyncRoute } from '../middleware/asyncRoute.mjs'

export function registerUserRoutes(app) {
  app.get(
    '/users/:id',
    requireAuth,
    asyncRoute(async (req, res) => {
      const id = Number(req.params.id)
      if (id !== req.user.userId) return res.status(403).json({ error: 'Forbidden' })
      const row = await dbGet('SELECT * FROM users WHERE id = ?', [id])
      if (!row) return res.status(404).json({ error: 'User not found' })
      res.json(rowToUser(row))
    }),
  )

  app.patch(
    '/users/:id',
    requireAuth,
    asyncRoute(async (req, res) => {
      const id = Number(req.params.id)
      if (id !== req.user.userId) return res.status(403).json({ error: 'Forbidden' })
      const allowed = ['name', 'displayName', 'phone', 'timezone', 'bio', 'workingHours']
      const sets = []
      const values = []
      for (const key of allowed) {
        if (!(key in (req.body || {}))) continue
        sets.push(`${key} = ?`)
        const value = req.body[key]
        values.push(key === 'workingHours' && value !== null ? JSON.stringify(value) : value)
      }
      if (sets.length) {
        values.push(id)
        await dbRun(`UPDATE users SET ${sets.join(', ')} WHERE id = ?`, values)
      }
      const row = await dbGet('SELECT * FROM users WHERE id = ?', [id])
      res.json(rowToUser(row))
    }),
  )
}
