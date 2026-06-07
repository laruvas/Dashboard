import { NavLink, Outlet, Link } from 'react-router-dom'
import type { ReactNode } from 'react'
import {
  IconDashboard, IconCalendar, IconServices, IconCheck,
  IconBell, IconUser, IconSearch, IconPlus,
} from '../components/Icons'
import { Avatar } from '../components/UI'
import { ThemeToggle, LangToggle } from '../components/Toggles'
import { useCommandPalette } from '../components/CommandPalette'
import { useT } from '../i18n/SettingsContext'
import { useAuth } from '../i18n/AuthContext'

// "Anna Smith" -> "AS"
function initialsFrom(name: string): string {
  if (!name) return '?'
  return name.trim().split(/\s+/).slice(0, 2).map(w => w[0]?.toUpperCase() || '').join('') || '?'
}

interface NavItemProps {
  to: string
  icon: ReactNode
  children: ReactNode
}

function NavItem({ to, icon, children }: NavItemProps) {
  return (
    <NavLink to={to} className={({ isActive }) => (isActive ? 'active' : '')}>
      {icon}
      <span>{children}</span>
    </NavLink>
  )
}

export default function AppLayout() {
  const t = useT()
  const { open: openPalette } = useCommandPalette()
  const { user } = useAuth()
  // ProtectedRoute guarantees user is non-null here, but guard anyway.
  const displayName = user?.name || '—'
  const displayEmail = user?.email || ''
  return (
    <div className="app">
      <aside className="sidebar">
        <Link to="/dashboard" className="logo">
          <span className="mark">S</span>
          <span>Slottr</span>
        </Link>

        <div className="nav">
          <NavItem to="/dashboard"     icon={<IconDashboard />}>{t('nav.dashboard')}</NavItem>
          <NavItem to="/booking"       icon={<IconCalendar />}>{t('nav.newBooking')}</NavItem>
          <NavItem to="/services"      icon={<IconServices />}>{t('nav.services')}</NavItem>
          <NavItem to="/bookings"      icon={<IconCheck />}>{t('nav.bookings')}</NavItem>
          <NavItem to="/notifications" icon={<IconBell />}>{t('nav.notifications')}</NavItem>

          <div className="section-label">{t('nav.account')}</div>
          <NavItem to="/profile" icon={<IconUser />}>{t('nav.profile')}</NavItem>
        </div>

        <div className="user">
          <Avatar initials={initialsFrom(displayName)} />
          <div style={{ flex: 1, minWidth: 0 }}>
            <div style={{ fontSize: 13, fontWeight: 600, overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>{displayName}</div>
            <div style={{ fontSize: 11.5, color: 'var(--text-muted)', overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>{displayEmail}</div>
          </div>
        </div>
      </aside>

      <main className="main">
        <div className="topbar">
          <button
            type="button"
            className="search"
            onClick={openPalette}
            aria-label={t('common.search')}
            style={{ cursor: 'pointer', textAlign: 'left' }}
          >
            <IconSearch />
            <span style={{ flex: 1, fontSize: 13 }}>{t('common.search')}</span>
            <span className="kbd">⌘ K</span>
          </button>
          <div className="flex flex-gap-2" style={{ alignItems: 'center' }}>
            <LangToggle />
            <ThemeToggle />
            <Link to="/notifications" className="btn btn-ghost btn-sm" title={t('common.notifications')}><IconBell /></Link>
            <Link to="/booking" className="btn btn-primary btn-sm"><IconPlus /> {t('nav.newBooking')}</Link>
          </div>
        </div>

        <Outlet />
      </main>
    </div>
  )
}
