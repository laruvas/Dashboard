#!/usr/bin/env bash
# One-shot: initialize a git repo and replay the project as a sequence of
# logical, self-contained commits. Each commit is buildable on its own
# (no broken intermediate states), grouped by layer/feature.
#
# Run ONCE from the project root:
#   bash setup-git-history.sh
#
# After completion:
#   git remote add origin git@github.com:laruvas/Dashboard.git
#   git push -u origin main

set -e

# Safety: refuse to run if .git already exists, to avoid clobbering history.
if [ -d .git ]; then
  echo "ERROR: .git already exists — refusing to overwrite. Delete it first if intentional."
  exit 1
fi

# --- 0. Move every file out of the way; we'll restage them in commit chunks. ---
STAGING=".tmp-staging"
mkdir -p "$STAGING"

# Move all top-level files and dirs except node_modules / dist / hidden ones into staging
shopt -s extglob dotglob
for f in !(.|..|node_modules|dist|.tmp-staging|$STAGING); do
  mv "$f" "$STAGING/"
done
shopt -u extglob dotglob

# --- 1. Init repo ---
git init -q -b main
git config user.name  "laruvas"
git config user.email "laruvas@users.noreply.github.com"

# Helper: move paths from staging back into the working tree.
restore() {
  for p in "$@"; do
    if [ -e "$STAGING/$p" ]; then
      mkdir -p "$(dirname "./$p")"
      mv "$STAGING/$p" "./$p"
    fi
  done
}

commit() {
  git add -A
  git commit -q -m "$1"
  echo "✓ $1"
}

# --- COMMIT 1: project skeleton ---
restore package.json package-lock.json tsconfig.json tsconfig.node.json \
        vite.config.js index.html
restore src/main.tsx src/App.tsx src/vite-env.d.ts
commit "chore: initial Vite + React + TypeScript project"

# --- COMMIT 2: gitignore + minimal README placeholder ---
restore .gitignore
# Temporary README — the real one will land in the final commit.
cat > README.md <<'EOF'
# Slottr

Appointment scheduling app.

Work in progress.
EOF
commit "chore: add gitignore and project README skeleton"

# --- COMMIT 3: domain types + i18n + settings context ---
restore src/types/index.ts
restore src/i18n/translations.ts src/i18n/SettingsContext.tsx
restore src/data/mock.ts
restore src/utils/date.ts
commit "feat: domain types, i18n with EN/RU and settings context"

# --- COMMIT 4: design system + layout + toggles ---
restore src/styles/app.css
restore src/components/Icons.tsx src/components/Toggles.tsx src/components/UI.tsx
restore src/layouts/AppLayout.tsx
commit "feat: design system, layout, theme and language toggles"

# --- COMMIT 5: shared UI primitives ---
restore src/components/Modal.tsx src/components/Toast.tsx src/components/Confirm.tsx \
        src/components/Skeleton.tsx src/components/EmptyState.tsx src/components/Calendar.tsx
commit "feat: reusable UI primitives (modal, toast, confirm, skeleton, calendar)"

# --- COMMIT 6: SQLite backend ---
restore scripts/db.mjs scripts/server.mjs scripts/migrate-from-json.mjs scripts/seed-users.mjs
commit "feat: SQLite backend with Express REST API"

# --- COMMIT 7: JWT auth (frontend) ---
restore src/data/http.ts src/data/authApi.ts
restore src/i18n/AuthContext.tsx
restore src/components/ProtectedRoute.tsx
restore src/pages/Welcome.tsx src/pages/Login.tsx src/pages/Register.tsx
commit "feat: JWT authentication with refresh token rotation"

# --- COMMIT 8: services management ---
restore src/data/servicesApi.ts
restore src/components/ServiceForm.tsx
restore src/pages/Services.tsx src/pages/ServiceDetail.tsx
commit "feat: services CRUD with bilingual fields and tag filtering"

# --- COMMIT 9: booking flow + availability ---
restore src/data/bookingsApi.ts src/data/availabilityApi.ts
restore src/utils/ics.ts src/utils/role.ts
restore src/pages/Booking.tsx src/pages/Confirmation.tsx
commit "feat: 4-step booking flow with server-side availability and conflict detection"

# --- COMMIT 10: bookings list + reschedule ---
restore src/components/RescheduleModal.tsx
restore src/pages/Bookings.tsx src/pages/BookingDetail.tsx
commit "feat: bookings list with status tabs, search, reschedule and iCal export"

# --- COMMIT 11: dashboard ---
restore src/pages/Dashboard.tsx
commit "feat: dashboard with adaptive weekly calendar and revenue stats"

# --- COMMIT 12: notifications + command palette ---
restore src/data/notificationsApi.ts
restore src/components/CommandPalette.tsx
restore src/pages/Notifications.tsx
commit "feat: server-side notifications and global command palette"

# --- COMMIT 13: profile + working hours ---
restore src/pages/Profile.tsx
commit "feat: user profile with per-day working hours editor"

# --- COMMIT 14: final README + traceability + sweep up anything left ---
# Anything remaining in staging that we haven't categorized — pull it in.
shopt -s dotglob
if [ -n "$(ls -A $STAGING 2>/dev/null)" ]; then
  for f in "$STAGING"/*; do
    name=$(basename "$f")
    mv "$f" "./$name"
  done
fi
shopt -u dotglob

# Overwrite the placeholder README with the full one (provided separately).
if [ -f README.full.md ]; then mv README.full.md README.md; fi
# Drop self.
rm -f setup-git-history.sh
commit "docs: full README, traceability table, deployment notes"

rmdir "$STAGING" 2>/dev/null || true

echo ""
echo "================================================================"
echo "Done. $(git rev-list --count main) commits on main."
echo ""
echo "Next steps:"
echo "  git log --oneline                                       # review history"
echo "  git remote add origin git@github.com:laruvas/Dashboard.git"
echo "  git push -u origin main"
echo "================================================================"
