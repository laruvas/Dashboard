import { dbRun } from '../db.mjs'

export async function pushNotification(userId, kind, params, tone) {
  await dbRun(`
    INSERT INTO notifications (userId, kind, tone, params, unread)
    VALUES (?, ?, ?, ?, 1)
  `, [userId, kind, tone || 'muted', JSON.stringify(params || {})])
}
