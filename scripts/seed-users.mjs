// One-time seed: creates two test users via the /register endpoint.
// Idempotent: skips users that already exist.
//
// Usage: `npm run seed:users` (requires `npm run server` to be running)

const BASE = process.env.API_URL || 'http://localhost:3001'

const seeds = [
  { name: 'Alex Kim', email: 'alex@slottr.app', password: 'demo1234' },
  { name: 'Maria Orlova', email: 'maria@slottr.app', password: 'demo1234' },
]

async function seedOne(user) {
  const res = await fetch(`${BASE}/register`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(user),
  })
  if (res.status === 201 || res.status === 200) {
    console.log(`✓ created  ${user.email}`)
    return
  }
  // json-server-auth returns 400 with body "Email already exists"
  const text = await res.text()
  if (text.includes('already exists')) {
    console.log(`· skip     ${user.email} (already exists)`)
    return
  }
  console.error(`✗ failed   ${user.email} — ${res.status} ${text}`)
}

;(async () => {
  try {
    for (const u of seeds) await seedOne(u)
  } catch {
    console.error('Server unreachable at', BASE)
    console.error('Run `npm run server` first.')
    process.exit(1)
  }
})()
