// Guards a route subtree behind authentication.
// If the user is not authenticated, redirects to /login and remembers
// the original location so we can return after a successful login.
//
// Usage in App.tsx:
//   <Route element={<ProtectedRoute />}>
//     <Route element={<AppLayout />}>
//       <Route path="/dashboard" element={<Dashboard />} />
//       ...
//     </Route>
//   </Route>

import { Navigate, Outlet, useLocation } from 'react-router-dom'
import { useAuth } from '../i18n/AuthContext'

export default function ProtectedRoute() {
  const { isAuthenticated } = useAuth()
  const location = useLocation()

  if (!isAuthenticated) {
    return <Navigate to="/login" replace state={{ from: location }} />
  }

  return <Outlet />
}
