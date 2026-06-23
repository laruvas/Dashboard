// Vitest config — node-only, server-side tests live in /tests.
//
// We deliberately don't add jsdom: the backend tests are HTTP-level
// integration via supertest, not browser-component tests. Frontend tests
// (when/if added) will sit in their own config or extend this one.

import { defineConfig } from 'vitest/config'

export default defineConfig({
  test: {
    environment: 'node',
    include: ['tests/**/*.test.mjs'],
    testTimeout: 10_000,
    hookTimeout: 10_000,
    fileParallelism: false,
    coverage: {
      provider: 'v8',
      reporter: ['text', 'html'],
      include: ['scripts/**/*.mjs'],
      exclude: ['scripts/migrate-from-json.mjs', 'scripts/seed-users.mjs', 'scripts/boot.mjs'],
    },
  },
})
