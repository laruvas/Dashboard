import { useEffect, useMemo, useState } from 'react'
import { useNavigate, useSearchParams } from 'react-router-dom'
import { createBooking, listBookings } from '../data/bookingsApi'
import { listServices } from '../data/servicesApi'
import { getAvailability } from '../data/availabilityApi'
import { loc } from '../data/mock'
import { useT, useSettings } from '../i18n/SettingsContext'
import { useDelayedFlag } from '../components/Skeleton'
import type { AvailabilitySlot, Booking, DayHours, Service } from '../types'
import type { CustomerForm, Step } from './booking/bookingTypes'
import {
  addMinutesHHMM, getBookingEventDates, initialsFrom,
  isDateInPast, toISODate, toMinutes,
} from './booking/bookingUtils'
import DetailsForm from './booking/DetailsForm'
import ServiceStep from './booking/ServiceStep'
import DateTimeStep from './booking/DateTimeStep'
import ConfirmStep from './booking/ConfirmStep'
import BookingHeader from './booking/BookingHeader'

export default function Booking() {
  const navigate = useNavigate()
  const [searchParams, setSearchParams] = useSearchParams()
  const preselectServiceId = searchParams.get('service')
  const t = useT()
  const { lang } = useSettings()

  const [step, setStep] = useState<Step>(1)
  const [selectedServiceId, setSelectedServiceId] = useState<string | null>(null)

  // Step 1 filter state
  const [step1Tag, setStep1Tag] = useState<string>('all')
  const [step1Query, setStep1Query] = useState('')

  const [date, setDate] = useState<Date>(() => new Date())
  const [time, setTime] = useState('11:00')

  // These are the EXTERNAL client's details (the person being booked into the
  // user's calendar), so we start empty — never prefill from the logged-in user.
  const [customer, setCustomer] = useState<CustomerForm>({ name: '', email: '', phone: '', notes: '' })
  const [termsAccepted, setTermsAccepted] = useState(false)
  const [termsError, setTermsError] = useState(false)

  const [services, setServices] = useState<Service[]>([])
  // Existing bookings — used to render orange dots on the calendar for days
  // where the user already has appointments.
  const [bookings, setBookings] = useState<Booking[]>([])
  const [loading, setLoading] = useState(true)
  const [saving, setSaving] = useState(false)
  const [error, setError] = useState('')
  const step1Loading = useDelayedFlag(loading)

  // Availability for the currently selected (service, date). Fetched on step 2.
  const [availSlots, setAvailSlots] = useState<AvailabilitySlot[]>([])
  const [availWindow, setAvailWindow] = useState<DayHours | null>(null)
  const [availLoading, setAvailLoading] = useState(false)
  const [availError, setAvailError] = useState<string | null>(null)

  const selectedService = useMemo<Service | null>(
    // Compare via String() to handle json-server's mixed number/string ids.
    () => services.find(s => String(s.id) === String(selectedServiceId)) || null,
    [services, selectedServiceId]
  )

  const dateLabel = date.toLocaleDateString(lang === 'ru' ? 'ru-RU' : 'en-US', { weekday: 'short', month: 'short', day: 'numeric' })
  const dateISO = useMemo(() => toISODate(date), [date])

  useEffect(() => {
    let mounted = true
    setLoading(true)
    Promise.all([listServices(), listBookings()])
      .then(([svcRows, bkRows]) => {
        if (!mounted) return
        setServices(Array.isArray(svcRows) ? svcRows : [])
        setBookings(Array.isArray(bkRows) ? bkRows : [])
      })
      .catch(() => {
        if (!mounted) return
        setServices([])
        setBookings([])
      })
      .finally(() => { if (mounted) setLoading(false) })
    return () => { mounted = false }
  }, [])

  // Days where the user has at least one non-cancelled booking — rendered as
  // orange dots under the day number in the calendar.
  const eventsOn = useMemo<Date[]>(() => getBookingEventDates(bookings), [bookings])

  // Preselect a service from ?service=<id> query param.
  // Compare via String() — json-server may return id as number but URL param is always a string.
  useEffect(() => {
    if (!preselectServiceId || services.length === 0) return
    const match = services.find(s => String(s.id) === String(preselectServiceId))
    if (!match) return
    setSelectedServiceId(String(match.id))
    setStep(2)
    setSearchParams({}, { replace: true })
  }, [preselectServiceId, services, setSearchParams])

  // Fetch availability from the server whenever the (service, date) pair changes.
  // The server knows about ALL provider's bookings (not just ones this user can see),
  // so this is the only way to avoid double-booking across customers.
  useEffect(() => {
    if (!selectedService) return
    let mounted = true
    setAvailLoading(true)
    setAvailError(null)
    getAvailability(selectedService.providerId, dateISO, selectedService.duration)
      .then((res) => {
        if (!mounted) return
        setAvailSlots(res.slots)
        setAvailWindow(res.workingHours)
      })
      .catch((err: unknown) => {
        if (!mounted) return
        setAvailSlots([])
        setAvailWindow(null)
        // 404 means the provider record vanished (orphan service). Tell the user
        // explicitly instead of pretending it's just a day off.
        const status = (err as { status?: number })?.status
        setAvailError(status === 404 ? t('booking.providerMissing') : t('booking.errorCreate'))
      })
      .finally(() => { if (mounted) setAvailLoading(false) })
    return () => { mounted = false }
  }, [selectedService, dateISO, t])

  // Split slots into morning (< 13:00) and afternoon for visual grouping.
  const morningSlots    = useMemo(() => availSlots.filter(s => toMinutes(s.time) <  13 * 60), [availSlots])
  const afternoonSlots  = useMemo(() => availSlots.filter(s => toMinutes(s.time) >= 13 * 60), [availSlots])
  const disabledTimeSet = useMemo(() => new Set(availSlots.filter(s => !s.available).map(s => s.time)), [availSlots])
  const allFreeTimes    = useMemo(() => availSlots.filter(s => s.available).map(s => s.time), [availSlots])
  const dayOff          = !availLoading && availWindow === null
  const hasFreeSlots    = allFreeTimes.length > 0

  const isPastDate = useMemo(() => isDateInPast(date), [date])

  // Auto-pick the first available slot when (date, slots) change, if current pick is invalid.
  useEffect(() => {
    if (availLoading || availSlots.length === 0) return
    const currentValid = availSlots.some(s => s.time === time && s.available)
    if (currentValid) return
    if (allFreeTimes.length > 0) setTime(allFreeTimes[0])
  }, [availSlots, allFreeTimes, time, availLoading])

  // ============== ACTIONS ==============

  const onPickService = (id: string) => {
    setSelectedServiceId(id)
    setStep(2)
  }

  const goToDetails = () => {
    setError('')
    if (isPastDate) {
      setError(t('booking.errorPastDate'))
      return
    }
    if (disabledTimeSet.has(time) || !hasFreeSlots) {
      setError(t('booking.errorSlotTaken'))
      return
    }
    setStep(3)
  }

  const onSubmitDetails = (data: CustomerForm) => {
    setCustomer(data)
    setStep(4)
  }

  const onConfirm = async () => {
    if (!termsAccepted) { setTermsError(true); return }
    setTermsError(false)
    setError('')
    if (!selectedService) { setStep(1); return }
    if (isPastDate) { setError(t('booking.errorPastDate')); setStep(2); return }
    if (disabledTimeSet.has(time)) { setError(t('booking.errorSlotTaken')); setStep(2); return }

    try {
      setSaving(true)
      const created = await createBooking({
        dateISO,
        time,
        endTime: addMinutesHHMM(time, selectedService.duration),
        durationMin: selectedService.duration,
        serviceId: selectedService.id,
        service: loc(selectedService.name, lang),
        total: selectedService.price,
        withName: customer.name,
        initials: initialsFrom(customer.name),
        status: 'confirmed',
        customerEmail: customer.email,
        customerPhone: customer.phone || null,
        notes: customer.notes || null,
      })
      sessionStorage.setItem('lastBooking', JSON.stringify(created))
      navigate('/confirmation')
    } catch {
      setError(t('booking.errorCreate'))
    } finally {
      setSaving(false)
    }
  }


  // ============== STEP 1 ==============
  if (step === 1) {
    return (
      <>
        <BookingHeader step={step} />
        <ServiceStep
          services={services}
          loading={loading}
          showSkeleton={step1Loading}
          selectedServiceId={selectedServiceId}
          selectedTag={step1Tag}
          query={step1Query}
          onTagChange={setStep1Tag}
          onQueryChange={setStep1Query}
          onPickService={onPickService}
        />
      </>
    )
  }

  // ============== STEP 2 ==============
  if (step === 2) {
    return (
      <>
        <BookingHeader step={step} />
        <DateTimeStep
          date={date}
          dateLabel={dateLabel}
          eventsOn={eventsOn}
          error={error}
          availabilityError={availError}
          dayOff={dayOff}
          morningSlots={morningSlots}
          afternoonSlots={afternoonSlots}
          selectedTime={time}
          selectedService={selectedService}
          availabilityLoading={availLoading}
          bookedSlotsCount={availSlots.length - allFreeTimes.length}
          continueDisabled={availLoading || !!availError || !selectedService || isPastDate || dayOff || !hasFreeSlots || disabledTimeSet.has(time)}
          onDateChange={setDate}
          onTimeChange={setTime}
          onBack={() => setStep(1)}
          onContinue={goToDetails}
        />
      </>
    )
  }

  // ============== STEP 3 ==============
  if (step === 3) {
    return (
      <>
        <BookingHeader step={step} />
        <DetailsForm
          defaultValues={customer}
          onSubmit={onSubmitDetails}
          onBack={() => setStep(2)}
        />
      </>
    )
  }

  // ============== STEP 4 ==============
  return (
    <>
      <BookingHeader step={step} />
      <ConfirmStep
        selectedService={selectedService}
        customer={customer}
        dateLabel={dateLabel}
        time={time}
        termsAccepted={termsAccepted}
        termsError={termsError}
        error={error}
        saving={saving}
        onTermsChange={(accepted) => {
          setTermsAccepted(accepted)
          if (accepted) setTermsError(false)
        }}
        onBack={() => setStep(3)}
        onConfirm={onConfirm}
      />
    </>
  )

}
