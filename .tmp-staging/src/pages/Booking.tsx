import { useEffect, useMemo, useState, type ChangeEvent, type FormEvent, type ReactNode } from 'react'
import { Link, useNavigate, useSearchParams } from 'react-router-dom'
import { Button, LabelMono, Card, Pill, Field, Divider } from '../components/UI'
import { IconSearch } from '../components/Icons'
import Calendar from '../components/Calendar'
import { createBooking, listBookings } from '../data/bookingsApi'
import { listServices } from '../data/servicesApi'
import { getAvailability } from '../data/availabilityApi'
import { loc } from '../data/mock'
import { useT, useSettings } from '../i18n/SettingsContext'
import EmptyState from '../components/EmptyState'
import { SkeletonCardGrid, useDelayedFlag } from '../components/Skeleton'
import type { AvailabilitySlot, Booking, DayHours, Service, Lang } from '../types'

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

// "10:00" -> 600 (minutes since 00:00)
function toMinutes(time: string): number {
  const [h, m] = time.split(':').map(Number)
  return h * 60 + m
}

// "Anna Smith" -> "AS"
function initialsFrom(name: string): string {
  if (!name) return '?'
  return name.trim().split(/\s+/).slice(0, 2).map(w => w[0]?.toUpperCase() || '').join('') || '?'
}

function matchesServiceQuery(s: Service, q: string, lang: Lang): boolean {
  if (!q) return true
  const haystack = [
    loc(s.name, lang), loc(s.description, lang), loc(s.tag, lang),
    s.name?.en, s.name?.ru, s.description?.en, s.description?.ru, s.tag?.en, s.tag?.ru,
  ].filter(Boolean).join(' ').toLowerCase()
  return haystack.includes(q.toLowerCase())
}

type Step = 1 | 2 | 3 | 4

interface CustomerForm {
  name: string
  email: string
  phone: string
  notes: string
}

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
  const eventsOn = useMemo<Date[]>(() => {
    const dates: Date[] = []
    for (const b of bookings) {
      if (!b.dateISO || b.status === 'cancelled') continue
      const [y, m, d] = b.dateISO.split('-').map(Number)
      if (!y || !m || !d) continue
      dates.push(new Date(y, m - 1, d))
    }
    return dates
  }, [bookings])

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
  }, [selectedService, dateISO])

  // Split slots into morning (< 13:00) and afternoon for visual grouping.
  const morningSlots    = useMemo(() => availSlots.filter(s => toMinutes(s.time) <  13 * 60), [availSlots])
  const afternoonSlots  = useMemo(() => availSlots.filter(s => toMinutes(s.time) >= 13 * 60), [availSlots])
  const disabledTimeSet = useMemo(() => new Set(availSlots.filter(s => !s.available).map(s => s.time)), [availSlots])
  const allFreeTimes    = useMemo(() => availSlots.filter(s => s.available).map(s => s.time), [availSlots])
  const dayOff          = !availLoading && availWindow === null
  const hasFreeSlots    = allFreeTimes.length > 0

  const isPastDate = useMemo(() => {
    const today = new Date()
    const todayMid = new Date(today.getFullYear(), today.getMonth(), today.getDate())
    const selectedMid = new Date(date.getFullYear(), date.getMonth(), date.getDate())
    return selectedMid < todayMid
  }, [date])

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

  const renderSlot = (slot: AvailabilitySlot) => (
    <button
      key={slot.time}
      className={`slot-btn ${time === slot.time ? 'selected' : ''}`}
      disabled={availLoading || !slot.available}
      onClick={() => setTime(slot.time)}
    >
      {slot.time}
    </button>
  )

  const stepper = (
    <div className="stepper">
      <div className={`step ${step === 1 ? 'active' : 'done'}`}><span className="num">1</span> {t('booking.step.service')}</div>
      <span className="sep">·</span>
      <div className={`step ${step === 2 ? 'active' : step > 2 ? 'done' : ''}`}><span className="num">2</span> {t('booking.step.dateTime')}</div>
      <span className="sep">·</span>
      <div className={`step ${step === 3 ? 'active' : step > 3 ? 'done' : ''}`}><span className="num">3</span> {t('booking.step.details')}</div>
      <span className="sep">·</span>
      <div className={`step ${step === 4 ? 'active' : ''}`}><span className="num">4</span> {t('booking.step.confirm')}</div>
    </div>
  )

  const header = (
    <>
      <Link to="/dashboard" className="btn-text">{t('booking.backToDashboard')}</Link>
      <h1 className="mt-4 mb-2">{t('booking.title')}</h1>
      <p className="subtitle mb-8">{t('booking.subtitle')}</p>
      {stepper}
    </>
  )

  // ============== STEP 1 ==============
  if (step === 1) {
    const matchedAll = services.filter(s => matchesServiceQuery(s, step1Query, lang))
    const seen = new Map<string, Service['tag']>()
    for (const s of services) {
      const key = s.tag?.en
      if (key && !seen.has(key)) seen.set(key, s.tag)
    }
    const filters = [
      { value: 'all', label: t('services.tab.all'), count: matchedAll.length },
      ...[...seen.entries()].map(([key, tag]) => ({
        value: key,
        label: loc(tag, lang),
        count: matchedAll.filter(s => s.tag?.en === key).length,
      })),
    ]

    let visible = services
    if (step1Tag !== 'all') visible = visible.filter(s => s.tag?.en === step1Tag)
    if (step1Query) visible = visible.filter(s => matchesServiceQuery(s, step1Query, lang))

    const isEmptySearch = !loading && services.length > 0 && visible.length === 0

    return (
      <>
        {header}

        <h3 className="mb-2">{t('booking.chooseService')}</h3>
        <p className="text-muted mb-6">{t('booking.chooseServiceSub')}</p>

        {loading && step1Loading && <SkeletonCardGrid />}

        {!loading && services.length === 0 && (
          <EmptyState
            illustration="services"
            title={t('booking.catalogEmpty')}
            description={t('booking.catalogEmpty.desc')}
            action={<Button as="link" to="/services">{t('services.add')}</Button>}
          />
        )}

        {!loading && services.length > 0 && (
          <>
            <div
              className="mb-6"
              style={{
                background: 'var(--bg-elev-1)',
                border: '1px solid var(--border)',
                borderRadius: 'var(--r-md)',
                padding: 'var(--s-2) var(--s-3)',
                display: 'flex', alignItems: 'center', gap: 'var(--s-2)',
                maxWidth: 420,
              }}
            >
              <IconSearch style={{ color: 'var(--text-muted)' }} />
              <input
                type="search"
                value={step1Query}
                onChange={(e) => setStep1Query(e.target.value)}
                placeholder={t('services.search.placeholder')}
                style={{
                  flex: 1, border: 'none', outline: 'none', background: 'none',
                  color: 'var(--text)', fontSize: 13,
                }}
              />
            </div>

            <div className="services-layout">
              <aside className="services-filters">
                <div className="filter-label">{t('services.filters')}</div>
                {filters.map(f => (
                  <button
                    key={f.value}
                    className={`filter-item ${step1Tag === f.value ? 'active' : ''}`}
                    onClick={() => setStep1Tag(f.value)}
                  >
                    <span>{f.label}</span>
                    <span className="count">{f.count}</span>
                  </button>
                ))}
              </aside>

              <div>
                {isEmptySearch ? (
                  <EmptyState illustration="search" title={t('services.search.empty')} />
                ) : (
                  <div className="services-grid">
                    {visible.map((s) => {
                      const isSelected = String(s.id) === String(selectedServiceId)
                      return (
                        <Card
                          key={s.id}
                          interactive
                          onClick={() => onPickService(s.id)}
                          style={isSelected ? { borderColor: 'var(--accent)' } : undefined}
                        >
                          <div className="flex-between mb-4">
                            <Pill tone={s.tone}>{loc(s.tag, lang)}</Pill>
                            <span className="mono text-muted" style={{ fontSize: 12 }}>{s.duration} {t('services.minutes')}</span>
                          </div>
                          <h3 className="mb-2">{loc(s.name, lang)}</h3>
                          <p className="text-muted line-clamp-3" style={{ fontSize: 13 }}>{loc(s.description, lang)}</p>
                          <div className="flex-between mt-auto" style={{ paddingTop: 'var(--s-6)' }}>
                            <span className="text-accent mono" style={{ fontSize: 16, fontWeight: 600 }}>${s.price}</span>
                            <Link
                              to={`/services/${s.id}`}
                              onClick={(e) => e.stopPropagation()}
                              className="btn-text"
                              style={{ fontSize: 13 }}
                            >
                              {t('services.details')}
                            </Link>
                          </div>
                        </Card>
                      )
                    })}
                  </div>
                )}
              </div>
            </div>
          </>
        )}
      </>
    )
  }

  // ============== STEP 2 ==============
  if (step === 2) {
    return (
      <>
        {header}

        <div className="grid" style={{ gridTemplateColumns: '1.1fr 1fr', gap: 'var(--s-6)' }}>
          <div>
            <h3 className="mb-4">{t('booking.pickDate')}</h3>
            <Calendar value={date} onChange={setDate} eventsOn={eventsOn} minDate={new Date()} />
          </div>

          <div>
            <div className="flex-between mb-4">
              <h3>{t('booking.availableTimes')}</h3>
              <LabelMono>{dateLabel}</LabelMono>
            </div>

            {error && <div className="card mb-4"><div>⚠ {error}</div></div>}

            {availError ? (
              <div className="card mb-4" style={{ borderColor: 'rgba(248,113,113,0.32)' }}>
                <div style={{ fontWeight: 600, color: 'var(--danger)' }}>⚠ {availError}</div>
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
                    {dateLabel} · {time}–{selectedService ? addMinutesHHMM(time, selectedService.duration) : time} ({selectedService?.duration || 60} {t('services.minutes')})
                  </div>
                </div>
                <div className="text-accent mono">${selectedService?.price ?? 0}</div>
              </div>
            </div>

            <div className="flex flex-gap-3">
              <Button variant="ghost" block onClick={() => setStep(1)}>{t('common.back')}</Button>
              <Button
                block
                onClick={goToDetails}
                disabled={availLoading || !!availError || !selectedService || isPastDate || dayOff || !hasFreeSlots || disabledTimeSet.has(time)}
              >
                {t('common.continue')}
              </Button>
            </div>

            <div className="text-muted mt-2">
              {availLoading
                ? t('booking.loadingBookings')
                : dayOff
                  ? ''
                  : t('booking.bookedSlots', { n: availSlots.length - allFreeTimes.length })}
            </div>
          </div>
        </div>
      </>
    )
  }

  // ============== STEP 3 ==============
  if (step === 3) {
    return (
      <>
        {header}
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
      {header}

      <h3 className="mb-2">{t('booking.confirm.title')}</h3>
      <p className="text-muted mb-6">{t('booking.confirm.sub')}</p>

      <Card className="mb-6" style={{ maxWidth: 640 }}>
        <SummaryRow label={t('booking.confirm.section.service')}>
          <div style={{ fontWeight: 600 }}>{selectedService ? loc(selectedService.name, lang) : '—'}</div>
          <div className="text-muted mt-2" style={{ fontSize: 13 }}>
            {selectedService?.duration} {t('services.minutes')} · ${selectedService?.price}
          </div>
        </SummaryRow>

        <Divider />

        <SummaryRow label={t('booking.confirm.section.when')}>
          <div style={{ fontWeight: 600 }}>{dateLabel}</div>
          <div className="mono text-muted mt-2" style={{ fontSize: 13 }}>
            {time}–{selectedService ? addMinutesHHMM(time, selectedService.duration) : time}
          </div>
        </SummaryRow>

        <Divider />

        <SummaryRow label={t('booking.confirm.section.customer')}>
          <div style={{ fontWeight: 600 }}>{customer.name}</div>
          <div className="text-muted mt-2" style={{ fontSize: 13 }}>{customer.email}</div>
          {customer.phone && <div className="text-muted mono" style={{ fontSize: 13 }}>{customer.phone}</div>}
        </SummaryRow>

        {customer.notes && (
          <>
            <Divider />
            <SummaryRow label={t('booking.confirm.section.notes')}>
              <div style={{ fontSize: 13, whiteSpace: 'pre-wrap' }}>{customer.notes}</div>
            </SummaryRow>
          </>
        )}
      </Card>

      <div style={{ maxWidth: 640 }}>
        <label className="flex flex-gap-3 mb-2" style={{ alignItems: 'flex-start', cursor: 'pointer', fontSize: 14 }}>
          <input
            type="checkbox"
            checked={termsAccepted}
            onChange={(e) => { setTermsAccepted(e.target.checked); if (e.target.checked) setTermsError(false) }}
            style={{ marginTop: 3 }}
          />
          <span>{t('booking.confirm.terms')}</span>
        </label>
        {termsError && (
          <div className="text-muted mb-4" style={{ color: 'var(--danger)', fontSize: 12 }}>
            {t('validation.terms')}
          </div>
        )}

        {error && <div className="card mb-4"><div>⚠ {error}</div></div>}

        <div className="flex flex-gap-3 mt-4">
          <Button variant="ghost" onClick={() => setStep(3)} disabled={saving}>{t('common.back')}</Button>
          <Button onClick={onConfirm} disabled={saving}>
            {saving ? t('booking.saving') : t('booking.confirm.btn')}
          </Button>
        </div>
      </div>
    </>
  )
}

// ============== SUB-COMPONENTS ==============

function SummaryRow({ label, children }: { label: ReactNode; children: ReactNode }) {
  return (
    <div className="flex" style={{ gap: 'var(--s-6)', padding: 'var(--s-3) 0' }}>
      <div style={{ width: 120, flex: 'none' }}>
        <LabelMono>{label}</LabelMono>
      </div>
      <div style={{ flex: 1, minWidth: 0 }}>{children}</div>
    </div>
  )
}

const EMAIL_RE = /^[^@\s]+@[^@\s]+\.[^@\s]+$/
const PHONE_RE = /^[+\d\s()\-]{6,}$/

type TFn = ReturnType<typeof useT>
type DetailsErrors = Partial<Record<keyof CustomerForm, string>>

function validateDetails(values: CustomerForm, t: TFn): DetailsErrors {
  const errors: DetailsErrors = {}
  if (!values.name.trim()) errors.name = t('validation.required')
  if (!values.email.trim()) errors.email = t('validation.required')
  else if (!EMAIL_RE.test(values.email.trim())) errors.email = t('validation.email')
  if (values.phone.trim() && !PHONE_RE.test(values.phone.trim())) errors.phone = t('validation.phone')
  return errors
}

interface DetailsFormProps {
  defaultValues: CustomerForm
  onSubmit: (data: CustomerForm) => void
  onBack: () => void
}

function DetailsForm({ defaultValues, onSubmit, onBack }: DetailsFormProps) {
  const t = useT()
  const [values, setValues] = useState<CustomerForm>(defaultValues)
  const [errors, setErrors] = useState<DetailsErrors>({})
  const [touched, setTouched] = useState<Partial<Record<keyof CustomerForm, boolean>>>({})

  const setField = (k: keyof CustomerForm) =>
    (e: ChangeEvent<HTMLInputElement | HTMLTextAreaElement>) => {
      const v = e.target.value
      setValues(prev => ({ ...prev, [k]: v }))
      if (touched[k] || errors[k]) {
        setErrors(validateDetails({ ...values, [k]: v }, t))
      }
    }
  const markTouched = (k: keyof CustomerForm) => () => {
    setTouched(prev => ({ ...prev, [k]: true }))
    setErrors(validateDetails(values, t))
  }

  const submit = (e: FormEvent<HTMLFormElement>) => {
    e.preventDefault()
    const errs = validateDetails(values, t)
    setErrors(errs)
    setTouched({ name: true, email: true, phone: true })
    if (Object.keys(errs).length === 0) {
      onSubmit({
        name: values.name.trim(),
        email: values.email.trim(),
        phone: values.phone.trim(),
        notes: values.notes.trim(),
      })
    }
  }

  return (
    <form onSubmit={submit} noValidate style={{ maxWidth: 560 }}>
      <h3 className="mb-6">{t('booking.yourDetails')}</h3>

      <Field label={t('booking.field.name')}>
        <input
          className="input"
          autoComplete="name"
          value={values.name}
          onChange={setField('name')}
          onBlur={markTouched('name')}
          aria-invalid={!!errors.name}
        />
        {errors.name && <FieldError>{errors.name}</FieldError>}
      </Field>

      <Field label={t('booking.field.email')}>
        <input
          className="input"
          type="email"
          autoComplete="email"
          value={values.email}
          onChange={setField('email')}
          onBlur={markTouched('email')}
          aria-invalid={!!errors.email}
        />
        {errors.email && <FieldError>{errors.email}</FieldError>}
      </Field>

      <Field label={t('booking.field.phone')}>
        <input
          className="input"
          type="tel"
          autoComplete="tel"
          value={values.phone}
          onChange={setField('phone')}
          onBlur={markTouched('phone')}
          aria-invalid={!!errors.phone}
        />
        {errors.phone && <FieldError>{errors.phone}</FieldError>}
      </Field>

      <Field label={t('booking.field.notes')}>
        <textarea
          className="textarea"
          placeholder={t('booking.field.notes.ph')}
          value={values.notes}
          onChange={setField('notes')}
        />
      </Field>

      <div className="flex flex-gap-3 mt-4">
        <Button variant="ghost" type="button" onClick={onBack}>{t('common.back')}</Button>
        <Button type="submit">{t('common.continue')}</Button>
      </div>
    </form>
  )
}

function FieldError({ children }: { children: ReactNode }) {
  return <span style={{ color: 'var(--danger)', fontSize: 12, marginTop: 4 }}>{children}</span>
}
