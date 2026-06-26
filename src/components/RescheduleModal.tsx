// Reschedule a booking: pick new date + time slot, PATCH on confirm.
// Re-uses the same /availability endpoint as the booking flow so conflicts
// with existing bookings on the new day are reflected as disabled slots.

import { useEffect, useMemo, useState } from 'react'
import Modal from './Modal'
import { Button, Field } from './UI'
import { getAvailability } from '../data/availabilityApi'
import { useT } from '../i18n/SettingsContext'
import type { AvailabilitySlot, Booking } from '../types'

interface RescheduleModalProps {
  booking: Booking | null
  onClose: () => void
  onSubmit: (dateISO: string, time: string) => Promise<void>
}

function toISODate(d: Date): string {
  const yyyy = d.getFullYear()
  const mm = String(d.getMonth() + 1).padStart(2, '0')
  const dd = String(d.getDate()).padStart(2, '0')
  return `${yyyy}-${mm}-${dd}`
}

function addMinutesHHMM(time: string, minutesToAdd: number): string {
  const [hStr, mStr] = time.split(':')
  const total = Number(hStr) * 60 + Number(mStr) + minutesToAdd
  const h = String(Math.floor(total / 60) % 24).padStart(2, '0')
  const m = String(total % 60).padStart(2, '0')
  return `${h}:${m}`
}

export default function RescheduleModal({ booking, onClose, onSubmit }: RescheduleModalProps) {
  const t = useT()
  const [dateISO, setDateISO] = useState('')
  const [time, setTime] = useState('')
  const [slots, setSlots] = useState<AvailabilitySlot[]>([])
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState<string | null>(null)
  const [saving, setSaving] = useState(false)

  // Re-seed local state whenever a new booking is passed in.
  useEffect(() => {
    if (!booking) return
    setDateISO(booking.dateISO || toISODate(new Date()))
    setTime(booking.time || '')
    setError(null)
  }, [booking])

  // Fetch availability for the chosen date/provider.
  useEffect(() => {
    if (!booking || !dateISO) return
    let mounted = true
    setLoading(true)
    setError(null)
    getAvailability(booking.providerId, dateISO, booking.durationMin || 60)
      .then((res) => {
        if (mounted) setSlots(res.slots)
      })
      .catch(() => {
        if (mounted) {
          setSlots([])
          setError(t('booking.providerMissing'))
        }
      })
      .finally(() => {
        if (mounted) setLoading(false)
      })
    return () => {
      mounted = false
    }
  }, [booking, dateISO, t])

  const todayISO = useMemo(() => toISODate(new Date()), [])
  const freeTimes = useMemo(
    // Allow keeping the current slot even if it shows up as "taken" (by this same booking).
    () =>
      slots.filter(
        (s) => s.available || (booking && s.time === booking.time && dateISO === booking.dateISO),
      ),
    [slots, booking, dateISO],
  )

  const isCurrentSelection = booking && dateISO === booking.dateISO && time === booking.time
  const canSubmit = !!time && !saving && !loading && !error && !isCurrentSelection

  const submit = async () => {
    if (!canSubmit) return
    try {
      setSaving(true)
      await onSubmit(dateISO, time)
      onClose()
    } catch (e) {
      setError(e instanceof Error ? e.message : 'Failed')
    } finally {
      setSaving(false)
    }
  }

  if (!booking) return null

  return (
    <Modal open={!!booking} onClose={() => !saving && onClose()} title={t('bookings.action.edit')}>
      <div className="text-muted mb-4" style={{ fontSize: 13 }}>
        {booking.service}
        {booking.withName ? ` · ${booking.withName}` : ''}
      </div>

      <Field label={t('booking.pickDate')}>
        <input
          className="input mono"
          type="date"
          min={todayISO}
          value={dateISO}
          onChange={(e) => setDateISO(e.target.value)}
        />
      </Field>

      <Field label={t('booking.availableTimes')}>
        {loading ? (
          <div className="text-muted" style={{ fontSize: 13 }}>
            {t('booking.loadingBookings')}
          </div>
        ) : error ? (
          <div style={{ color: 'var(--danger)', fontSize: 13 }}>{error}</div>
        ) : freeTimes.length === 0 ? (
          <div className="text-muted" style={{ fontSize: 13 }}>
            {t('booking.dayOff')}
          </div>
        ) : (
          <div className="slots">
            {freeTimes.map((s) => (
              <button
                key={s.time}
                type="button"
                className={`slot-btn ${time === s.time ? 'selected' : ''}`}
                onClick={() => setTime(s.time)}
              >
                {s.time}
              </button>
            ))}
          </div>
        )}
      </Field>

      {time && (
        <div className="text-muted mt-2" style={{ fontSize: 13 }}>
          {time}–{addMinutesHHMM(time, booking.durationMin || 60)} ({booking.durationMin || 60}{' '}
          {t('services.minutes')})
        </div>
      )}

      <div className="flex flex-gap-3 mt-6" style={{ justifyContent: 'flex-end' }}>
        <Button variant="ghost" type="button" onClick={onClose} disabled={saving}>
          {t('common.cancel')}
        </Button>
        <Button type="button" onClick={submit} disabled={!canSubmit}>
          {saving ? t('common.loading') : t('common.save')}
        </Button>
      </div>
    </Modal>
  )
}
