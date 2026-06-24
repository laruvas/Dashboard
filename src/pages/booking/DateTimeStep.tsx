import { Button, LabelMono } from '../../components/UI'
import Calendar from '../../components/Calendar'
import { loc } from '../../data/mock'
import { useT, useSettings } from '../../i18n/SettingsContext'
import type { AvailabilitySlot, Service } from '../../types'
import { addMinutesHHMM } from './bookingUtils'

interface DateTimeStepProps {
  date: Date
  dateLabel: string
  eventsOn: Date[]
  error: string
  availabilityError: string | null
  dayOff: boolean
  morningSlots: AvailabilitySlot[]
  afternoonSlots: AvailabilitySlot[]
  selectedTime: string
  selectedService: Service | null
  availabilityLoading: boolean
  bookedSlotsCount: number
  continueDisabled: boolean
  onDateChange: (date: Date) => void
  onTimeChange: (time: string) => void
  onBack: () => void
  onContinue: () => void
}

export default function DateTimeStep({
  date,
  dateLabel,
  eventsOn,
  error,
  availabilityError,
  dayOff,
  morningSlots,
  afternoonSlots,
  selectedTime,
  selectedService,
  availabilityLoading,
  bookedSlotsCount,
  continueDisabled,
  onDateChange,
  onTimeChange,
  onBack,
  onContinue,
}: DateTimeStepProps) {
  const t = useT()
  const { lang } = useSettings()

  const renderSlot = (slot: AvailabilitySlot) => (
    <button
      key={slot.time}
      className={`slot-btn ${selectedTime === slot.time ? 'selected' : ''}`}
      disabled={availabilityLoading || !slot.available}
      onClick={() => onTimeChange(slot.time)}
    >
      {slot.time}
    </button>
  )

  return (
    <div className="grid" style={{ gridTemplateColumns: '1.1fr 1fr', gap: 'var(--s-6)' }}>
      <div>
        <h3 className="mb-4">{t('booking.pickDate')}</h3>
        <Calendar value={date} onChange={onDateChange} eventsOn={eventsOn} minDate={new Date()} />
      </div>

      <div>
        <div className="flex-between mb-4">
          <h3>{t('booking.availableTimes')}</h3>
          <LabelMono>{dateLabel}</LabelMono>
        </div>

        {error && <div className="card mb-4"><div>⚠ {error}</div></div>}

        {availabilityError ? (
          <div className="card mb-4" style={{ borderColor: 'rgba(248,113,113,0.32)' }}>
            <div style={{ fontWeight: 600, color: 'var(--danger)' }}>⚠ {availabilityError}</div>
          </div>
        ) : dayOff ? (
          <div className="card mb-4">
            <div style={{ fontWeight: 600 }}>{t('booking.dayOff')}</div>
            <div className="text-muted mt-2" style={{ fontSize: 13 }}>{t('booking.dayOff.desc')}</div>
          </div>
        ) : (
          <>
            <div className="mb-4">
              <LabelMono>{t('booking.morning')}</LabelMono>
              <div className="slots mt-2">{morningSlots.map(renderSlot)}</div>
            </div>

            <div className="mb-6">
              <LabelMono>{t('booking.afternoon')}</LabelMono>
              <div className="slots mt-2">{afternoonSlots.map(renderSlot)}</div>
            </div>
          </>
        )}

        <div className="card mb-4">
          <LabelMono>{t('booking.yourSelection')}</LabelMono>
          <div className="flex-between mt-2">
            <div>
              <div>{selectedService ? loc(selectedService.name, lang) : '—'}</div>
              <div className="text-muted mt-2">
                {dateLabel} · {selectedTime}–{selectedService ? addMinutesHHMM(selectedTime, selectedService.duration) : selectedTime} ({selectedService?.duration || 60} {t('services.minutes')})
              </div>
            </div>
            <div className="text-accent mono">${selectedService?.price ?? 0}</div>
          </div>
        </div>

        <div className="flex flex-gap-3">
          <Button variant="ghost" block onClick={onBack}>{t('common.back')}</Button>
          <Button block onClick={onContinue} disabled={continueDisabled}>
            {t('common.continue')}
          </Button>
        </div>

        <div className="text-muted mt-2">
          {availabilityLoading
            ? t('booking.loadingBookings')
            : dayOff
              ? ''
              : t('booking.bookedSlots', { n: bookedSlotsCount })}
        </div>
      </div>
    </div>
  )
}
