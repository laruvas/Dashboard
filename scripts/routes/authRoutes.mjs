import bcrypt from 'bcryptjs'
import { hashRefresh } from '../auth.mjs'
import { BCRYPT_ROUNDS } from '../config.mjs'
import { dbGet, dbRun, rowToUser } from '../db.mjs'
import { asyncRoute } from '../middleware/asyncRoute.mjs'
import { consumeRefreshToken, issueAccessToken, issueRefreshToken } from '../services/tokenService.mjs'

const EMAIL_RE = /^[^\s@]+@[^\s@]+\.[^\s@]+$/

export function registerAuthRoutes(app) {
  app.post('/register', asyncRoute(async (req, res) => {
    const { email, password, name } = req.body || {}
    if (!email || !EMAIL_RE.test(String(email))) return res.status(400).json({ error: 'Valid email required' })
    if (!password || String(password).length < 6) return res.status(400).json({ error: 'Password must be at least 6 characters' })
    if (!name || !String(name).trim()) return res.status(400).json({ error: 'Name required' })

    const passwordHash = bcrypt.hashSync(String(password), BCRYPT_ROUNDS)
    let info
    try {
      info = await dbRun(
        'INSERT INTO users (email, passwordHash, name) VALUES (?, ?, ?)',
        [String(email).toLowerCase(), passwordHash, String(name).trim()],
      )
    } catch (e) {
      if (String(e.message).includes('UNIQUE')) return res.status(400).json({ error: 'Email already exists' })
      return res.status(500).json({ error: 'Could not create user' })
    }

    const user = rowToUser(await dbGet('SELECT * FROM users WHERE id = ?', [info.lastInsertRowid]))
    res.status(201).json({
      accessToken: issueAccessToken(user),
      refreshToken: await issueRefreshToken(user.id),
      user,
    })
  }))

  app.post('/login', asyncRoute(async (req, res) => {
    const { email, password } = req.body || {}
    if (!email || !password) return res.status(400).json({ error: 'Email and password required' })
    const row = await dbGet('SELECT * FROM users WHERE email = ?', [String(email).toLowerCase()])
    if (!row || !bcrypt.compareSync(String(password), row.passwordHash)) {
      return res.status(400).json({ error: 'Incorrect email or password' })
    }
    const user = rowToUser(row)
    res.json({
      accessToken: issueAccessToken(user),
      refreshToken: await issueRefreshToken(user.id),
      user,
    })
  }))

  app.post('/refresh', asyncRoute(async (req, res) => {
    const session = await consumeRefreshToken(req.body?.refreshToken)
    if (!session) return res.status(401).json({ error: 'Invalid or expired refresh token' })
    await dbRun('DELETE FROM refresh_tokens WHERE id = ?', [Number(session.tokenRow.id)])
    res.json({
      accessToken: issueAccessToken(session.user),
      refreshToken: await issueRefreshToken(session.user.id),
      user: session.user,
    })
  }))

  app.post('/logout', asyncRoute(async (req, res) => {
    const presented = req.body?.refreshToken
    if (presented) await dbRun('DELETE FROM refresh_tokens WHERE tokenHash = ?', [hashRefresh(presented)])
    res.json({ ok: true })
  }))
}
