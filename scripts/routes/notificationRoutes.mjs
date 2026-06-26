import { dbAll, dbGet, dbRun, rowToNotification } from '../db.mjs'
import { requireAuth } from '../middleware/authMiddleware.mjs'
import { asyncRoute } from '../middleware/asyncRoute.mjs'

export function registerNotificationRoutes(app) {
  app.get(
    '/notifications',
    requireAuth,
    asyncRoute(async (req, res) => {
      const rows = await dbAll(
        `
      SELECT * FROM notifications WHERE userId = ? ORDER BY createdAt DESC
    `,
        [req.user.userId],
      )
      res.json(rows.map(rowToNotification))
    }),
  )

  app.patch(
    '/notifications/:id',
    requireAuth,
    asyncRoute(async (req, res) => {
      const id = Number(req.params.id)
      const row = await dbGet('SELECT * FROM notifications WHERE id = ?', [id])
      if (!row) return res.status(404).json({ error: 'Notification not found' })
      if (Number(row.userId) !== req.user.userId)
        return res.status(403).json({ error: 'Not the owner' })
      if (typeof req.body?.unread === 'boolean') {
        await dbRun('UPDATE notifications SET unread = ? WHERE id = ?', [
          req.body.unread ? 1 : 0,
          id,
        ])
      }
      const updated = await dbGet('SELECT * FROM notifications WHERE id = ?', [id])
      res.json(rowToNotification(updated))
    }),
  )

  app.post(
    '/notifications/mark-all-read',
    requireAuth,
    asyncRoute(async (req, res) => {
      await dbRun('UPDATE notifications SET unread = 0 WHERE userId = ? AND unread = 1', [
        req.user.userId,
      ])
      res.json({ ok: true })
    }),
  )

  app.delete(
    '/notifications/:id',
    requireAuth,
    asyncRoute(async (req, res) => {
      const id = Number(req.params.id)
      const row = await dbGet('SELECT * FROM notifications WHERE id = ?', [id])
      if (!row) return res.status(404).json({ error: 'Notification not found' })
      if (Number(row.userId) !== req.user.userId)
        return res.status(403).json({ error: 'Not the owner' })
      await dbRun('DELETE FROM notifications WHERE id = ?', [id])
      res.status(204).end()
    }),
  )
}
