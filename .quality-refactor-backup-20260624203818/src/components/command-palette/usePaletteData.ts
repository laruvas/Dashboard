import { useEffect, useState } from 'react'
import { listBookings } from '../../data/bookingsApi'
import { listServices } from '../../data/servicesApi'
import type { Booking, Service } from '../../types'

export function usePaletteData(): {
  services: Service[]
  bookings: Booking[]
  loading: boolean
} {
  const [services, setServices] = useState<Service[]>([])
  const [bookings, setBookings] = useState<Booking[]>([])
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    let mounted = true
    Promise.all([listServices(), listBookings()])
      .then(([s, b]) => {
        if (!mounted) return
        setServices(s)
        setBookings(b)
      })
      .catch(() => { /* silent — palette still usable */ })
      .finally(() => { if (mounted) setLoading(false) })
    return () => { mounted = false }
  }, [])

  return { services, bookings, loading }
}
