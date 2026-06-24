#!/usr/bin/env bash
set -euo pipefail

# Quality refactor installer for Slottr/Dashboard project.
# Run from the repository root.

if [ ! -f "package.json" ] || [ ! -d "src" ]; then
  echo "Run this script from the repository root" >&2
  exit 1
fi

BACKUP_DIR=".refactor-backup-$(date +%Y%m%d%H%M%S)"
mkdir -p "$BACKUP_DIR"

backup_file() {
  local path="$1"
  if [ -f "$path" ]; then
    mkdir -p "$BACKUP_DIR/$(dirname "$path")"
    cp "$path" "$BACKUP_DIR/$path"
  fi
}

write_file() {
  local path="$1"
  backup_file "$path"
  mkdir -p "$(dirname "$path")"
  cat > "$path"
}

echo "Installing quality refactor files..."

write_file 'src/components/CommandPalette.tsx' <<'QUALITY_REFACTOR_FILE'
// Global command palette (⌘K / Ctrl+K).
// Searches services + bookings, keyboard navigation, jumps to detail pages.
//
// Usage:
//   <CommandPaletteProvider>
//     <App />
//   </CommandPaletteProvider>
//
//   const { open } = useCommandPalette()
//   open()  // programmatically

import { createContext, useCallback, useContext, useMemo, useState, type ReactNode } from 'react'
import Palette from './command-palette/Palette'
import { useGlobalCommandShortcut } from './command-palette/useGlobalCommandShortcut'
import type { CommandPaletteContextValue } from './command-palette/commandPaletteTypes'

const CommandPaletteContext = createContext<CommandPaletteContextValue | null>(null)

export function CommandPaletteProvider({ children }: { children: ReactNode }) {
  const [isOpen, setOpen] = useState(false)

  const open = useCallback(() => setOpen(true), [])
  const close = useCallback(() => setOpen(false), [])

  useGlobalCommandShortcut(open)

  const value = useMemo<CommandPaletteContextValue>(() => ({ open, close }), [open, close])

  return (
    <CommandPaletteContext.Provider value={value}>
      {children}
      {isOpen && <Palette onClose={close} />}
    </CommandPaletteContext.Provider>
  )
}

export function useCommandPalette(): CommandPaletteContextValue {
  const ctx = useContext(CommandPaletteContext)
  if (!ctx) throw new Error('useCommandPalette must be used inside <CommandPaletteProvider>')
  return ctx
}
QUALITY_REFACTOR_FILE

write_file 'src/components/ServiceForm.tsx' <<'QUALITY_REFACTOR_FILE'
import { useState, type ChangeEvent, type FormEvent } from 'react'
import { Button } from './UI'
import { useT } from '../i18n/SettingsContext'
import type { Service, ServicePayload } from '../types'
import ServiceBasicsFields from './service-form/ServiceBasicsFields'
import ServiceDetailsFields from './service-form/ServiceDetailsFields'
import type { ServiceFormErrors, ServiceFormTouched, ServiceFormValues } from './service-form/serviceFormTypes'
import { toServiceFormValues, toServicePayload, validateServiceForm } from './service-form/serviceFormUtils'

interface ServiceFormProps {
  service: Service | null
  onSubmit: (payload: ServicePayload) => void
  onCancel: () => void
  saving?: boolean
}

export default function ServiceForm({ service, onSubmit, onCancel, saving = false }: ServiceFormProps) {
  const t = useT()
  const [values, setValues] = useState<ServiceFormValues>(() => toServiceFormValues(service))
  const [errors, setErrors] = useState<ServiceFormErrors>({})
  const [touched, setTouched] = useState<ServiceFormTouched>({})

  const setField = (key: keyof ServiceFormValues) =>
    (e: ChangeEvent<HTMLInputElement | HTMLTextAreaElement | HTMLSelectElement>) => {
      const value = e.target.value
      setValues(prev => {
        const next = { ...prev, [key]: value }
        if (touched[key] || errors[key]) setErrors(validateServiceForm(next, t))
        return next
      })
    }

  const markTouched = (key: keyof ServiceFormValues) => () => {
    setTouched(prev => ({ ...prev, [key]: true }))
    setErrors(validateServiceForm(values, t))
  }

  const submit = (e: FormEvent<HTMLFormElement>) => {
    e.preventDefault()
    const nextErrors = validateServiceForm(values, t)
    setErrors(nextErrors)
    setTouched({
      tagEn: true, tagRu: true, nameEn: true, nameRu: true,
      descEn: true, descRu: true, duration: true, price: true,
    })
    if (Object.keys(nextErrors).length === 0) onSubmit(toServicePayload(values))
  }

  return (
    <form onSubmit={submit} noValidate>
      <ServiceBasicsFields
        values={values}
        errors={errors}
        setField={setField}
        markTouched={markTouched}
      />

      <ServiceDetailsFields
        values={values}
        errors={errors}
        setField={setField}
        markTouched={markTouched}
      />

      <div className="flex flex-gap-3 mt-4" style={{ justifyContent: 'flex-end' }}>
        <Button variant="ghost" type="button" onClick={onCancel} disabled={saving}>{t('common.cancel')}</Button>
        <Button type="submit" disabled={saving}>
          {saving ? t('common.loading') : (service ? t('common.save') : t('serviceForm.create'))}
        </Button>
      </div>
    </form>
  )
}
QUALITY_REFACTOR_FILE

write_file 'src/components/command-palette/CommandResults.tsx' <<'QUALITY_REFACTOR_FILE'
import type { ReactNode } from 'react'
import { SkeletonList } from '../Skeleton'
import { useT } from '../../i18n/SettingsContext'
import type { ResultItem } from './commandPaletteTypes'
import { splitResultGroups } from './commandPaletteUtils'

interface CommandResultsProps {
  query: string
  loading: boolean
  results: ResultItem[]
  activeIdx: number
  onPick: (item: ResultItem) => void
  onHover: (idx: number) => void
}

export default function CommandResults({
  query,
  loading,
  results,
  activeIdx,
  onPick,
  onHover,
}: CommandResultsProps) {
  const t = useT()
  const { serviceItems, bookingItems } = splitResultGroups(results)

  return (
    <div style={{ overflowY: 'auto', flex: 1, padding: 'var(--s-2) 0' }}>
      {loading && query && <SkeletonList count={4} />}

      {!loading && !query && (
        <div className="empty" style={{ padding: 'var(--s-8)' }}>{t('palette.empty.start')}</div>
      )}

      {!loading && query && results.length === 0 && (
        <div className="empty" style={{ padding: 'var(--s-8)' }}>{t('palette.empty.noResults')}</div>
      )}

      {results.length > 0 && (
        <>
          {serviceItems.length > 0 && (
            <Group title={t('palette.group.services')}>
              {serviceItems.map((item) => {
                const idx = results.indexOf(item)
                return (
                  <ResultRow
                    key={item.id}
                    item={item}
                    active={idx === activeIdx}
                    onClick={() => onPick(item)}
                    onHover={() => onHover(idx)}
                  />
                )
              })}
            </Group>
          )}

          {bookingItems.length > 0 && (
            <Group title={t('palette.group.bookings')}>
              {bookingItems.map((item) => {
                const idx = results.indexOf(item)
                return (
                  <ResultRow
                    key={item.id}
                    item={item}
                    active={idx === activeIdx}
                    onClick={() => onPick(item)}
                    onHover={() => onHover(idx)}
                  />
                )
              })}
            </Group>
          )}
        </>
      )}
    </div>
  )
}

function Group({ title, children }: { title: ReactNode; children: ReactNode }) {
  return (
    <div style={{ marginBottom: 'var(--s-2)' }}>
      <div style={{
        padding: 'var(--s-2) var(--s-5)',
        fontFamily: 'var(--font-mono)',
        fontSize: 11,
        color: 'var(--text-subtle)',
        textTransform: 'uppercase',
        letterSpacing: '0.06em',
      }}>{title}</div>
      {children}
    </div>
  )
}

function ResultRow({
  item, active, onClick, onHover,
}: {
  item: ResultItem
  active: boolean
  onClick: () => void
  onHover: () => void
}) {
  return (
    <button
      type="button"
      onClick={onClick}
      onMouseEnter={onHover}
      style={{
        display: 'block', width: '100%', textAlign: 'left',
        padding: 'var(--s-3) var(--s-5)',
        background: active ? 'var(--bg-hover)' : 'transparent',
        color: 'var(--text)',
        cursor: 'pointer',
        borderLeft: `2px solid ${active ? 'var(--accent)' : 'transparent'}`,
      }}
    >
      <div style={{ fontWeight: 500, fontSize: 14 }}>{item.title}</div>
      <div style={{ fontSize: 12, color: 'var(--text-muted)', marginTop: 2 }}>{item.subtitle}</div>
    </button>
  )
}
QUALITY_REFACTOR_FILE

write_file 'src/components/command-palette/Palette.tsx' <<'QUALITY_REFACTOR_FILE'
import { useCallback, useEffect, useMemo, useRef, useState, type ReactNode } from 'react'
import { useNavigate } from 'react-router-dom'
import { IconSearch } from '../Icons'
import { useT, useSettings } from '../../i18n/SettingsContext'
import CommandResults from './CommandResults'
import { buildPaletteResults } from './commandPaletteUtils'
import type { ResultItem } from './commandPaletteTypes'
import { useBodyScrollLock } from './useBodyScrollLock'
import { usePaletteData } from './usePaletteData'

interface PaletteProps {
  onClose: () => void
}

export default function Palette({ onClose }: PaletteProps) {
  const navigate = useNavigate()
  const t = useT()
  const { lang } = useSettings()
  const inputRef = useRef<HTMLInputElement | null>(null)

  const [query, setQuery] = useState('')
  const [activeIdx, setActiveIdx] = useState(0)
  const { services, bookings, loading } = usePaletteData()

  useBodyScrollLock()

  // Auto-focus input on mount.
  useEffect(() => {
    inputRef.current?.focus()
  }, [])

  const results = useMemo<ResultItem[]>(
    () => buildPaletteResults({ query, services, bookings, lang, t }),
    [query, services, bookings, lang, t],
  )

  // Reset active index when results change.
  useEffect(() => { setActiveIdx(0) }, [results])

  const goTo = useCallback((to: string) => {
    onClose()
    navigate(to)
  }, [navigate, onClose])

  const pickItem = useCallback((item: ResultItem) => {
    goTo(item.to)
  }, [goTo])

  const onKeyDown = (e: React.KeyboardEvent) => {
    if (e.key === 'Escape') { e.preventDefault(); onClose(); return }
    if (results.length === 0) return

    if (e.key === 'ArrowDown') {
      e.preventDefault()
      setActiveIdx(i => (i + 1) % results.length)
    } else if (e.key === 'ArrowUp') {
      e.preventDefault()
      setActiveIdx(i => (i - 1 + results.length) % results.length)
    } else if (e.key === 'Enter') {
      e.preventDefault()
      const item = results[activeIdx]
      if (item) pickItem(item)
    }
  }

  return (
    <div
      onMouseDown={(e) => { if (e.target === e.currentTarget) onClose() }}
      style={{
        position: 'fixed', inset: 0, zIndex: 150,
        background: 'rgba(0,0,0,0.5)',
        display: 'flex', justifyContent: 'center',
        padding: '15vh var(--s-4) var(--s-4)',
      }}
    >
      <div
        role="dialog"
        aria-modal="true"
        aria-label="Command palette"
        onKeyDown={onKeyDown}
        style={{
          width: '100%', maxWidth: 600, maxHeight: '70vh',
          background: 'var(--bg-elev-1)',
          border: '1px solid var(--border)',
          borderRadius: 'var(--r-lg)',
          boxShadow: 'var(--shadow-md)',
          display: 'flex', flexDirection: 'column',
          overflow: 'hidden',
        }}
      >
        <div style={{
          display: 'flex', alignItems: 'center', gap: 'var(--s-3)',
          padding: 'var(--s-4) var(--s-5)',
          borderBottom: '1px solid var(--border)',
        }}>
          <IconSearch style={{ color: 'var(--text-muted)' }} />
          <input
            ref={inputRef}
            type="search"
            value={query}
            onChange={(e) => setQuery(e.target.value)}
            placeholder={t('palette.placeholder')}
            style={{
              flex: 1, border: 'none', outline: 'none', background: 'none',
              color: 'var(--text)', fontSize: 15,
            }}
          />
        </div>

        <CommandResults
          query={query}
          loading={loading}
          results={results}
          activeIdx={activeIdx}
          onPick={pickItem}
          onHover={setActiveIdx}
        />

        <PaletteFooter />
      </div>
    </div>
  )
}

function PaletteFooter() {
  const t = useT()

  return (
    <div style={{
      display: 'flex', gap: 'var(--s-4)', justifyContent: 'flex-end',
      padding: 'var(--s-3) var(--s-5)',
      borderTop: '1px solid var(--border)',
      fontSize: 11, color: 'var(--text-subtle)',
    }}>
      <span><Kbd>↑↓</Kbd> {t('palette.hint.navigate')}</span>
      <span><Kbd>↵</Kbd> {t('palette.hint.select')}</span>
      <span><Kbd>Esc</Kbd> {t('palette.hint.close')}</span>
    </div>
  )
}

function Kbd({ children }: { children: ReactNode }) {
  return (
    <span style={{
      fontFamily: 'var(--font-mono)',
      background: 'var(--bg-elev-2)',
      padding: '1px 5px',
      borderRadius: 4,
      border: '1px solid var(--border)',
      marginRight: 4,
    }}>{children}</span>
  )
}
QUALITY_REFACTOR_FILE

write_file 'src/components/command-palette/commandPaletteTypes.ts' <<'QUALITY_REFACTOR_FILE'
export interface CommandPaletteContextValue {
  open: () => void
  close: () => void
}

export interface ResultItem {
  id: string
  group: 'services' | 'bookings'
  title: string
  subtitle: string
  to: string
}
QUALITY_REFACTOR_FILE

write_file 'src/components/command-palette/commandPaletteUtils.ts' <<'QUALITY_REFACTOR_FILE'
import { loc } from '../../data/mock'
import type { Booking, Lang, Service } from '../../types'
import type { TKey } from '../../i18n/translations'
import type { ResultItem } from './commandPaletteTypes'

type TFn = (key: TKey, params?: Record<string, string | number>) => string

export function isTypingTarget(target: EventTarget | null): boolean {
  if (!(target instanceof HTMLElement)) return false
  return /^(INPUT|TEXTAREA)$/.test(target.tagName)
}

export function isCommandK(e: KeyboardEvent): boolean {
  const isMac = navigator.platform.toUpperCase().includes('MAC')
  const cmd = isMac ? e.metaKey : e.ctrlKey
  return cmd && e.key.toLowerCase() === 'k'
}

export function buildPaletteResults({
  query,
  services,
  bookings,
  lang,
  t,
}: {
  query: string
  services: Service[]
  bookings: Booking[]
  lang: Lang
  t: TFn
}): ResultItem[] {
  if (!query.trim()) return []

  const q = query.toLowerCase()
  const items: ResultItem[] = []

  for (const s of services) {
    const haystack = [
      loc(s.name, lang), loc(s.description, lang), loc(s.tag, lang),
      s.name?.en, s.name?.ru, s.tag?.en, s.tag?.ru,
    ].filter(Boolean).join(' ').toLowerCase()

    if (haystack.includes(q)) {
      items.push({
        id: `service-${s.id}`,
        group: 'services',
        title: loc(s.name, lang),
        subtitle: `${loc(s.tag, lang)} · ${s.duration} ${t('services.minutes')} · $${s.price}`,
        to: `/services/${s.id}`,
      })
    }
  }

  for (const b of bookings) {
    const haystack = [
      b.service, b.withName, b.customerEmail, b.customerPhone, b.notes, b.dateISO, b.time,
    ].filter(Boolean).join(' ').toLowerCase()

    if (haystack.includes(q)) {
      items.push({
        id: `booking-${b.id}`,
        group: 'bookings',
        title: `${b.service} — ${b.withName || '—'}`,
        subtitle: `${b.dateISO} · ${b.time}${b.endTime ? `–${b.endTime}` : ''} · ${b.customerEmail}`,
        to: `/bookings/${b.id}`,
      })
    }
  }

  return items.slice(0, 20)
}

export function splitResultGroups(results: ResultItem[]): {
  serviceItems: ResultItem[]
  bookingItems: ResultItem[]
} {
  return {
    serviceItems: results.filter(r => r.group === 'services'),
    bookingItems: results.filter(r => r.group === 'bookings'),
  }
}
QUALITY_REFACTOR_FILE

write_file 'src/components/command-palette/useBodyScrollLock.ts' <<'QUALITY_REFACTOR_FILE'
import { useEffect } from 'react'

export function useBodyScrollLock(): void {
  useEffect(() => {
    const prevFocused = document.activeElement
    document.body.style.overflow = 'hidden'

    return () => {
      document.body.style.overflow = ''
      if (prevFocused instanceof HTMLElement) prevFocused.focus()
    }
  }, [])
}
QUALITY_REFACTOR_FILE

write_file 'src/components/command-palette/useGlobalCommandShortcut.ts' <<'QUALITY_REFACTOR_FILE'
import { useEffect } from 'react'
import { isCommandK, isTypingTarget } from './commandPaletteUtils'

export function useGlobalCommandShortcut(onOpen: () => void): void {
  useEffect(() => {
    const onKey = (e: KeyboardEvent) => {
      if (!isCommandK(e)) return
      // Don't hijack if user is typing in an input/textarea.
      if (isTypingTarget(e.target)) return
      e.preventDefault()
      onOpen()
    }

    window.addEventListener('keydown', onKey)
    return () => window.removeEventListener('keydown', onKey)
  }, [onOpen])
}
QUALITY_REFACTOR_FILE

write_file 'src/components/command-palette/usePaletteData.ts' <<'QUALITY_REFACTOR_FILE'
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
QUALITY_REFACTOR_FILE

write_file 'src/components/service-form/FieldError.tsx' <<'QUALITY_REFACTOR_FILE'
import type { ReactNode } from 'react'

export default function FieldError({ children }: { children: ReactNode }) {
  return <span style={{ color: 'var(--danger)', fontSize: 12, marginTop: 4 }}>{children}</span>
}
QUALITY_REFACTOR_FILE

write_file 'src/components/service-form/ServiceBasicsFields.tsx' <<'QUALITY_REFACTOR_FILE'
import type { ChangeEvent } from 'react'
import { Field } from '../UI'
import { useT } from '../../i18n/SettingsContext'
import type { ServiceFormErrors, ServiceFormValues } from './serviceFormTypes'
import FieldError from './FieldError'

interface ServiceBasicsFieldsProps {
  values: ServiceFormValues
  errors: ServiceFormErrors
  setField: (key: keyof ServiceFormValues) => (e: ChangeEvent<HTMLInputElement | HTMLTextAreaElement | HTMLSelectElement>) => void
  markTouched: (key: keyof ServiceFormValues) => () => void
}

export default function ServiceBasicsFields({ values, errors, setField, markTouched }: ServiceBasicsFieldsProps) {
  const t = useT()

  return (
    <div className="grid grid-2">
      <Field label={t('serviceForm.tag.en')}>
        <input
          className="input"
          value={values.tagEn}
          onChange={setField('tagEn')}
          onBlur={markTouched('tagEn')}
          aria-invalid={!!errors.tagEn}
          placeholder="Strategy, Consultation, ..."
        />
        {errors.tagEn && <FieldError>{errors.tagEn}</FieldError>}
      </Field>

      <Field label={t('serviceForm.tag.ru')}>
        <input
          className="input"
          value={values.tagRu}
          onChange={setField('tagRu')}
          onBlur={markTouched('tagRu')}
          aria-invalid={!!errors.tagRu}
          placeholder="Стратегия, Консультация, ..."
        />
        {errors.tagRu && <FieldError>{errors.tagRu}</FieldError>}
      </Field>

      <Field label={t('serviceForm.name.en')}>
        <input
          className="input"
          value={values.nameEn}
          onChange={setField('nameEn')}
          onBlur={markTouched('nameEn')}
          aria-invalid={!!errors.nameEn}
        />
        {errors.nameEn && <FieldError>{errors.nameEn}</FieldError>}
      </Field>

      <Field label={t('serviceForm.name.ru')}>
        <input
          className="input"
          value={values.nameRu}
          onChange={setField('nameRu')}
          onBlur={markTouched('nameRu')}
          aria-invalid={!!errors.nameRu}
        />
        {errors.nameRu && <FieldError>{errors.nameRu}</FieldError>}
      </Field>

      <Field label={t('serviceForm.duration')}>
        <input
          className="input"
          type="number"
          min={1}
          value={values.duration}
          onChange={setField('duration')}
          onBlur={markTouched('duration')}
          aria-invalid={!!errors.duration}
        />
        {errors.duration && <FieldError>{errors.duration}</FieldError>}
      </Field>

      <Field label={t('serviceForm.price')}>
        <input
          className="input"
          type="number"
          min={0}
          value={values.price}
          onChange={setField('price')}
          onBlur={markTouched('price')}
          aria-invalid={!!errors.price}
        />
        {errors.price && <FieldError>{errors.price}</FieldError>}
      </Field>
    </div>
  )
}
QUALITY_REFACTOR_FILE

write_file 'src/components/service-form/ServiceDetailsFields.tsx' <<'QUALITY_REFACTOR_FILE'
import type { ChangeEvent } from 'react'
import { Field } from '../UI'
import { useT } from '../../i18n/SettingsContext'
import type { ServiceFormErrors, ServiceFormValues } from './serviceFormTypes'
import FieldError from './FieldError'

interface ServiceDetailsFieldsProps {
  values: ServiceFormValues
  errors: ServiceFormErrors
  setField: (key: keyof ServiceFormValues) => (e: ChangeEvent<HTMLInputElement | HTMLTextAreaElement | HTMLSelectElement>) => void
  markTouched: (key: keyof ServiceFormValues) => () => void
}

export default function ServiceDetailsFields({ values, errors, setField, markTouched }: ServiceDetailsFieldsProps) {
  const t = useT()

  return (
    <>
      <Field label={t('serviceForm.tone')}>
        <select className="select" value={values.tone} onChange={setField('tone')}>
          <option value="muted">{t('serviceForm.tone.muted')}</option>
          <option value="accent">{t('serviceForm.tone.accent')}</option>
        </select>
      </Field>

      <Field label={t('serviceForm.desc.en')}>
        <textarea
          className="textarea"
          value={values.descEn}
          onChange={setField('descEn')}
          onBlur={markTouched('descEn')}
          aria-invalid={!!errors.descEn}
        />
        {errors.descEn && <FieldError>{errors.descEn}</FieldError>}
      </Field>

      <Field label={t('serviceForm.desc.ru')}>
        <textarea
          className="textarea"
          value={values.descRu}
          onChange={setField('descRu')}
          onBlur={markTouched('descRu')}
          aria-invalid={!!errors.descRu}
        />
        {errors.descRu && <FieldError>{errors.descRu}</FieldError>}
      </Field>
    </>
  )
}
QUALITY_REFACTOR_FILE

write_file 'src/components/service-form/serviceFormTypes.ts' <<'QUALITY_REFACTOR_FILE'
import type { PillTone } from '../../types'

export interface ServiceFormValues {
  tagEn: string
  tagRu: string
  tone: PillTone
  duration: number | string
  price: number | string
  nameEn: string
  nameRu: string
  descEn: string
  descRu: string
}

export type ServiceFormErrors = Partial<Record<keyof ServiceFormValues, string>>
export type ServiceFormTouched = Partial<Record<keyof ServiceFormValues, boolean>>
QUALITY_REFACTOR_FILE

write_file 'src/components/service-form/serviceFormUtils.ts' <<'QUALITY_REFACTOR_FILE'
import type { Service, ServicePayload } from '../../types'
import type { TKey } from '../../i18n/translations'
import type { ServiceFormErrors, ServiceFormValues } from './serviceFormTypes'

export const EMPTY_SERVICE_FORM: ServiceFormValues = {
  tagEn: '',
  tagRu: '',
  tone: 'muted',
  duration: 60,
  price: 50,
  nameEn: '',
  nameRu: '',
  descEn: '',
  descRu: '',
}

type TFn = (key: TKey, params?: Record<string, string | number>) => string

export function toServiceFormValues(service: Service | null): ServiceFormValues {
  if (!service) return EMPTY_SERVICE_FORM
  return {
    tagEn: service.tag?.en || '',
    tagRu: service.tag?.ru || '',
    tone: service.tone || 'muted',
    duration: service.duration ?? 60,
    price: service.price ?? 50,
    nameEn: service.name?.en || '',
    nameRu: service.name?.ru || '',
    descEn: service.description?.en || '',
    descRu: service.description?.ru || '',
  }
}

export function toServicePayload(values: ServiceFormValues): ServicePayload {
  return {
    tag: { en: String(values.tagEn).trim(), ru: String(values.tagRu).trim() },
    tone: values.tone,
    duration: Number(values.duration),
    price: Number(values.price),
    name: { en: String(values.nameEn).trim(), ru: String(values.nameRu).trim() },
    description: { en: String(values.descEn).trim(), ru: String(values.descRu).trim() },
  }
}

export function validateServiceForm(values: ServiceFormValues, t: TFn): ServiceFormErrors {
  const errors: ServiceFormErrors = {}
  if (!String(values.tagEn).trim()) errors.tagEn = t('validation.required')
  if (!String(values.tagRu).trim()) errors.tagRu = t('validation.required')
  if (!String(values.nameEn).trim()) errors.nameEn = t('validation.required')
  if (!String(values.nameRu).trim()) errors.nameRu = t('validation.required')
  if (!String(values.descEn).trim()) errors.descEn = t('validation.required')
  if (!String(values.descRu).trim()) errors.descRu = t('validation.required')

  const duration = Number(values.duration)
  if (!Number.isFinite(duration) || duration <= 0) errors.duration = t('validation.positiveNumber')

  const price = Number(values.price)
  if (!Number.isFinite(price) || price < 0) errors.price = t('validation.nonNegativeNumber')

  return errors
}
QUALITY_REFACTOR_FILE

write_file 'src/pages/Booking.tsx' <<'QUALITY_REFACTOR_FILE'
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
QUALITY_REFACTOR_FILE

write_file 'src/pages/BookingDetail.tsx' <<'QUALITY_REFACTOR_FILE'
import { useEffect, useState } from 'react'
import { useNavigate, useParams } from 'react-router-dom'
import { getBooking, patchBooking, deleteBooking } from '../data/bookingsApi'
import { useT } from '../i18n/SettingsContext'
import { useConfirm } from '../components/Confirm'
import { useToast } from '../components/Toast'
import { useDelayedFlag } from '../components/Skeleton'
import type { Booking } from '../types'
import BookingDetailActions from './booking-detail/BookingDetailActions'
import BookingCustomerCard from './booking-detail/BookingCustomerCard'
import BookingDetailHeader from './booking-detail/BookingDetailHeader'
import { BookingDetailNotFound, BookingDetailSkeleton } from './booking-detail/BookingDetailState'
import BookingNotesCard from './booking-detail/BookingNotesCard'
import BookingSummaryCard from './booking-detail/BookingSummaryCard'

export default function BookingDetail() {
  const t = useT()
  const confirm = useConfirm()
  const toast = useToast()
  const { id } = useParams<{ id: string }>()
  const navigate = useNavigate()

  const [booking, setBooking] = useState<Booking | null>(null)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)
  const [busy, setBusy] = useState(false)

  // Back to wherever the user came from; fallback to /bookings if no history.
  const goBack = () => {
    if (window.history.length > 1) navigate(-1)
    else navigate('/bookings')
  }

  useEffect(() => {
    if (!id) return
    let mounted = true
    setLoading(true)
    getBooking(id)
      .then((data) => { if (mounted) { setBooking(data); setError(null) } })
      .catch(() => { if (mounted) setError(t('bookings.detail.notFound')) })
      .finally(() => { if (mounted) setLoading(false) })
    return () => { mounted = false }
  }, [id, t])

  const onCancel = async () => {
    if (!booking) return
    const ok = await confirm({
      title: t('bookings.action.cancel'),
      message: t('bookings.cancelConfirm', {
        service: booking.service,
        date: booking.dateISO,
        time: booking.time,
      }),
      confirmText: t('bookings.action.cancel'),
      danger: true,
    })
    if (!ok) return

    try {
      setBusy(true)
      await patchBooking(booking.id, { status: 'cancelled' })
      setBooking({ ...booking, status: 'cancelled' })
      toast.success(t('bookings.action.cancel'))
    } catch (e) {
      toast.error(e instanceof Error ? e.message : 'Failed to cancel')
    } finally {
      setBusy(false)
    }
  }

  const onDelete = async () => {
    if (!booking) return
    const ok = await confirm({
      title: t('bookings.action.delete'),
      message: t('bookings.deleteConfirm', {
        service: booking.service,
        date: booking.dateISO,
        time: booking.time,
      }),
      confirmText: t('bookings.action.delete'),
      danger: true,
    })
    if (!ok) return

    try {
      setBusy(true)
      await deleteBooking(booking.id)
      toast.success(t('bookings.action.delete'))
      navigate('/bookings')
    } catch (e) {
      toast.error(e instanceof Error ? e.message : 'Failed to delete')
      setBusy(false)
    }
  }

  const showSkeleton = useDelayedFlag(loading)
  if (loading) return showSkeleton ? <BookingDetailSkeleton /> : null

  if (error || !booking) {
    return <BookingDetailNotFound title={error || t('bookings.detail.notFound')} onBack={goBack} />
  }

  return (
    <div style={{ maxWidth: 720 }}>
      <BookingDetailHeader booking={booking} onBack={goBack} />
      <BookingSummaryCard booking={booking} />
      <BookingCustomerCard booking={booking} />
      <BookingNotesCard booking={booking} />
      <BookingDetailActions booking={booking} busy={busy} onCancel={onCancel} onDelete={onDelete} />
    </div>
  )
}
QUALITY_REFACTOR_FILE

write_file 'src/pages/Bookings.tsx' <<'QUALITY_REFACTOR_FILE'
import { useCallback, useEffect, useMemo, useState } from 'react'
import RescheduleModal from '../components/RescheduleModal'
import { listBookings, deleteBooking, patchBooking } from '../data/bookingsApi'
import { useT, useSettings } from '../i18n/SettingsContext'
import { useConfirm } from '../components/Confirm'
import { useToast } from '../components/Toast'
import { useDelayedFlag } from '../components/Skeleton'
import type { Booking } from '../types'
import type { TabItem } from '../components/UI'
import BookingsHeader from './bookings/BookingsHeader'
import BookingsFilters from './bookings/BookingsFilters'
import BookingsTable from './bookings/BookingsTable'
import {
  BookingsError,
  BookingsSkeleton,
  EmptyBookingsState,
  FirstRunEmptyState,
} from './bookings/BookingsState'
import type { StatusTab } from './bookings/bookingsTypes'
import {
  addMinutesHHMM,
  annotateBookings,
  filterBookings,
  formatDateShort,
  groupBookingsByStatus,
  sortBookings,
} from './bookings/bookingsUtils'

export default function Bookings() {
  const t = useT()
  const { lang } = useSettings()
  const confirm = useConfirm()
  const toast = useToast()

  const [status, setStatus] = useState<StatusTab>('upcoming')
  const [query, setQuery] = useState('')
  const [editing, setEditing] = useState<Booking | null>(null)
  const [bookings, setBookings] = useState<Booking[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)
  const [busyId, setBusyId] = useState<string | null>(null)

  const load = useCallback(() => {
    setLoading(true)
    listBookings()
      .then((data) => {
        setBookings(sortBookings(data))
        setError(null)
      })
      .catch(() => setError(t('bookings.errorServer')))
      .finally(() => setLoading(false))
  }, [t])

  useEffect(() => { load() }, [load])

  // Wrap into uniform shape so downstream code (which used to read `.b`/`.role`)
  // still works after the role-split was removed in the single-tenant refactor.
  const annotated = useMemo(() => annotateBookings(bookings), [bookings])
  const groups = useMemo(() => groupBookingsByStatus(annotated), [annotated])
  const visible = useMemo(() => filterBookings(groups, status, query), [groups, status, query])

  const handleReschedule = async (dateISO: string, time: string) => {
    if (!editing) return
    const endTime = addMinutesHHMM(time, editing.durationMin || 60)
    const updated = await patchBooking(editing.id, { dateISO, time, endTime })
    setBookings(prev => prev.map(x => x.id === editing.id ? { ...x, ...updated } : x))
    toast.success(t('common.save'))
  }

  const handleCancel = async (b: Booking) => {
    const ok = await confirm({
      title: t('bookings.action.cancel'),
      message: t('bookings.cancelConfirm', {
        service: b.service,
        date: formatDateShort(b.dateISO, lang),
        time: b.time,
      }),
      confirmText: t('bookings.action.cancel'),
      danger: true,
    })
    if (!ok) return

    try {
      setBusyId(b.id)
      await patchBooking(b.id, { status: 'cancelled' })
      setBookings(prev => prev.map(x => x.id === b.id ? { ...x, status: 'cancelled' } : x))
      toast.success(t('bookings.action.cancel'))
    } catch (e) {
      toast.error(e instanceof Error ? e.message : 'Failed to cancel booking')
    } finally {
      setBusyId(null)
    }
  }

  const handleDelete = async (b: Booking) => {
    const ok = await confirm({
      title: t('bookings.action.delete'),
      message: t('bookings.deleteConfirm', {
        service: b.service,
        date: formatDateShort(b.dateISO, lang),
        time: b.time,
      }),
      confirmText: t('bookings.action.delete'),
      danger: true,
    })
    if (!ok) return

    try {
      setBusyId(b.id)
      await deleteBooking(b.id)
      setBookings(prev => prev.filter(x => x.id !== b.id))
      toast.success(t('bookings.action.delete'))
    } catch (e) {
      toast.error(e instanceof Error ? e.message : 'Failed to delete booking')
    } finally {
      setBusyId(null)
    }
  }

  // Hide tab counts while loading — they'd flicker from 0 → N once data arrives.
  const count = (n: number) => loading ? undefined : n
  const tabs: TabItem<StatusTab>[] = [
    { value: 'upcoming', label: t('bookings.tab.upcoming'), count: count(groups.upcoming.length) },
    { value: 'past', label: t('bookings.tab.past'), count: count(groups.past.length) },
    { value: 'cancelled', label: t('bookings.tab.cancelled'), count: count(groups.cancelled.length) },
  ]

  const showSkeleton = useDelayedFlag(loading)
  const isFirstRun = !loading && !error && annotated.length === 0

  return (
    <>
      <BookingsHeader loading={loading} onRefresh={load} />

      {!isFirstRun && (
        <BookingsFilters
          tabs={tabs}
          status={status}
          query={query}
          onStatusChange={setStatus}
          onQueryChange={setQuery}
        />
      )}

      {error && <BookingsError error={error} />}
      {!error && loading && showSkeleton && <BookingsSkeleton />}
      {isFirstRun && <FirstRunEmptyState />}
      {!error && !loading && !isFirstRun && visible.length === 0 && (
        <EmptyBookingsState status={status} query={query} />
      )}
      {visible.length > 0 && (
        <BookingsTable
          items={visible}
          status={status}
          busyId={busyId}
          onEdit={setEditing}
          onCancel={handleCancel}
          onDelete={handleDelete}
        />
      )}

      <RescheduleModal
        booking={editing}
        onClose={() => setEditing(null)}
        onSubmit={handleReschedule}
      />
    </>
  )
}
QUALITY_REFACTOR_FILE

write_file 'src/pages/Dashboard.tsx' <<'QUALITY_REFACTOR_FILE'
import { useEffect, useMemo, useState } from 'react'
import { listBookings } from '../data/bookingsApi'
import { useT } from '../i18n/SettingsContext'
import { useAuth } from '../i18n/AuthContext'
import { addDays, isSameDay, startOfWeek } from '../utils/date'
import type { Booking } from '../types'
import DashboardHeader from './dashboard/DashboardHeader'
import DashboardStatsGrid from './dashboard/DashboardStatsGrid'
import WeekCalendar from './dashboard/WeekCalendar'
import UpcomingBookings from './dashboard/UpcomingBookings'
import {
  calculateDashboardStats,
  getHourBounds,
  getHours,
  getUpcomingBookings,
  groupWeekEvents,
} from './dashboard/dashboardUtils'
import { useDelayedFlag } from '../components/Skeleton'

export default function Dashboard() {
  const t = useT()
  const { user } = useAuth()
  const userId = user?.id
  // Greeting prefers displayName (e.g. "Anna"), falls back to full name's first word.
  const greetingName = user?.displayName || user?.name?.split(' ')[0] || ''

  const [rawBookings, setRawBookings] = useState<Booking[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  // Current week shown in the week-calendar (mutable via prev/today/next).
  const [weekAnchor, setWeekAnchor] = useState<Date>(() => new Date())

  useEffect(() => {
    let mounted = true
    listBookings()
      .then((data) => { if (mounted) { setRawBookings(data); setError(null) } })
      .catch(() => { if (mounted) setError(t('dashboard.errorServer')) })
      .finally(() => { if (mounted) setLoading(false) })
    return () => { mounted = false }
  }, [t])

  // Dashboard is the "specialist panel": only show bookings where the current
  // user is the PROVIDER. Customer-side bookings live in /bookings under
  // the "Mine" scope.
  const bookings = useMemo(
    () => userId == null ? [] : rawBookings.filter(b => Number(b.providerId) === userId),
    [rawBookings, userId],
  )

  const stats = useMemo(() => calculateDashboardStats(bookings), [bookings])

  const weekStart = useMemo(() => startOfWeek(weekAnchor), [weekAnchor])
  const days = useMemo(() => Array.from({ length: 7 }, (_, i) => addDays(weekStart, i)), [weekStart])
  const weekEventsByDay = useMemo(
    () => groupWeekEvents(bookings, weekAnchor, days),
    [bookings, weekAnchor, days],
  )
  const hourBounds = useMemo(() => getHourBounds(weekEventsByDay), [weekEventsByDay])
  const hours = useMemo(() => getHours(hourBounds), [hourBounds])
  const upcoming = useMemo(() => getUpcomingBookings(bookings), [bookings])

  const today = new Date()
  const isCurrentWeek = isSameDay(startOfWeek(today), weekStart)
  const showSkeleton = useDelayedFlag(loading)

  return (
    <>
      <DashboardHeader greetingName={greetingName} todayCount={stats.todayCount} />

      {error && (
        <div className="card mb-6" style={{ borderColor: 'rgba(248,113,113,0.32)', color: 'var(--danger)' }}>
          {error}
        </div>
      )}

      <DashboardStatsGrid stats={stats} loading={loading} showSkeleton={showSkeleton} />

      <WeekCalendar
        days={days}
        hours={hours}
        today={today}
        isCurrentWeek={isCurrentWeek}
        hourBounds={hourBounds}
        weekEventsByDay={weekEventsByDay}
        onPrevWeek={() => setWeekAnchor(addDays(weekAnchor, -7))}
        onToday={() => setWeekAnchor(new Date())}
        onNextWeek={() => setWeekAnchor(addDays(weekAnchor, 7))}
      />

      <UpcomingBookings
        bookings={upcoming}
        loading={loading}
        error={error}
        showSkeleton={showSkeleton}
      />
    </>
  )
}
QUALITY_REFACTOR_FILE

write_file 'src/pages/Profile.tsx' <<'QUALITY_REFACTOR_FILE'
import { useState, type ChangeEvent, type FormEvent } from 'react'
import { useNavigate } from 'react-router-dom'
import { Button } from '../components/UI'
import { useT, useSettings } from '../i18n/SettingsContext'
import { useAuth } from '../i18n/AuthContext'
import { useToast } from '../components/Toast'
import { useConfirm } from '../components/Confirm'
import type { ProfileFormValues } from './profile/profileTypes'
import ProfileFieldsCard from './profile/ProfileFieldsCard'
import AppearanceCard from './profile/AppearanceCard'
import WorkingHoursCard from './profile/WorkingHoursCard'
import { getInitialProfileForm } from './profile/profileUtils'

export default function Profile() {
  const t = useT()
  const toast = useToast()
  const confirm = useConfirm()
  const navigate = useNavigate()
  const { user, logout, updateProfile } = useAuth()
  const { lang, setLang, theme, setTheme } = useSettings()

  const [saving, setSaving] = useState(false)
  const [form, setForm] = useState<ProfileFormValues>(() => getInitialProfileForm(user))

  const updateField = (key: keyof ProfileFormValues) =>
    (e: ChangeEvent<HTMLInputElement | HTMLTextAreaElement | HTMLSelectElement>) => {
      setForm(prev => ({ ...prev, [key]: e.target.value }))
    }

  const handleLogout = async () => {
    const ok = await confirm({
      title: t('auth.logout'),
      confirmText: t('auth.logout'),
      danger: true,
    })
    if (!ok) return

    logout()
    toast.success(t('auth.loggedOut'))
    navigate('/login', { replace: true })
  }

  const save = async (e: FormEvent<HTMLFormElement>) => {
    e.preventDefault()
    if (saving) return

    setSaving(true)
    try {
      await updateProfile({
        name: form.fullName.trim(),
        displayName: form.displayName.trim() || undefined,
        email: form.email.trim(),
        phone: form.phone.trim() || undefined,
        timezone: form.timezone || undefined,
        bio: form.bio.trim() || undefined,
        workingHours: form.workingHours,
      })
      toast.success(t('profile.saved'))
    } catch {
      toast.error(t('profile.saveError'))
    } finally {
      setSaving(false)
    }
  }

  return (
    <>
      <h1 className="mb-2">{t('profile.title')}</h1>
      <p className="subtitle mb-8">{t('profile.subtitle')}</p>

      <div style={{ maxWidth: 880 }}>
        <form onSubmit={save}>
          <ProfileFieldsCard
            form={form}
            lang={lang}
            onFieldChange={updateField}
            onLangChange={setLang}
          />

          <AppearanceCard lang={lang} theme={theme} onThemeChange={setTheme} />

          <WorkingHoursCard
            value={form.workingHours}
            onChange={(workingHours) => setForm(prev => ({ ...prev, workingHours }))}
          />

          <div className="flex-between" style={{ alignItems: 'center' }}>
            <Button
              variant="ghost"
              type="button"
              onClick={handleLogout}
              style={{ color: 'var(--danger)' }}
            >
              {t('auth.logout')}
            </Button>
            <div className="flex flex-gap-3" style={{ alignItems: 'center' }}>
              <Button variant="ghost" type="button" disabled={saving}>{t('common.cancel')}</Button>
              <Button type="submit" disabled={saving}>
                {saving ? t('common.loading') : t('common.save')}
              </Button>
            </div>
          </div>
        </form>
      </div>
    </>
  )
}
QUALITY_REFACTOR_FILE

write_file 'src/pages/Services.tsx' <<'QUALITY_REFACTOR_FILE'
import { useCallback, useEffect, useMemo, useState } from 'react'
import Modal from '../components/Modal'
import ServiceForm from '../components/ServiceForm'
import { loc } from '../data/mock'
import { listServices, createService, patchService, deleteService } from '../data/servicesApi'
import { useT, useSettings } from '../i18n/SettingsContext'
import { useConfirm } from '../components/Confirm'
import { useToast } from '../components/Toast'
import { useDelayedFlag } from '../components/Skeleton'
import type { Service, ServicePayload } from '../types'
import ServicesHeader from './services/ServicesHeader'
import ServicesSearch from './services/ServicesSearch'
import ServicesGrid from './services/ServicesGrid'
import { EmptyServicesState, ServicesError, ServicesSkeleton } from './services/ServicesState'
import type { EditingState } from './services/servicesTypes'
import { isEditingService } from './services/servicesTypes'
import { buildServiceFilters, filterServices } from './services/servicesUtils'

export default function Services() {
  const t = useT()
  const { lang } = useSettings()
  const confirm = useConfirm()
  const toast = useToast()

  const [services, setServices] = useState<Service[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)
  const [tab, setTab] = useState<string>('all')
  const [query, setQuery] = useState('')
  const [editing, setEditing] = useState<EditingState>(null)
  const [saving, setSaving] = useState(false)
  const [busyId, setBusyId] = useState<string | null>(null)

  const load = useCallback((): Promise<void> => {
    setLoading(true)
    return listServices()
      .then((data) => { setServices(data); setError(null) })
      .catch(() => setError(t('services.errorServer')))
      .finally(() => setLoading(false))
  }, [t])

  useEffect(() => { void load() }, [load])

  const filters = useMemo(
    () => buildServiceFilters(services, query, lang, t('services.tab.all')),
    [services, query, lang, t],
  )
  const visible = useMemo(() => filterServices(services, tab, query, lang), [services, tab, query, lang])

  const openCreate = () => setEditing({ __new: true })
  const modalTitle = isEditingService(editing) ? t('services.modal.edit') : t('services.modal.create')
  const isEmptySearch = !loading && !error && services.length > 0 && visible.length === 0
  const showSkeleton = useDelayedFlag(loading)

  const onDelete = async (service: Service) => {
    const ok = await confirm({
      title: t('services.action.delete'),
      message: t('services.deleteConfirm', { name: loc(service.name, lang) }),
      confirmText: t('services.action.delete'),
      danger: true,
    })
    if (!ok) return

    try {
      setBusyId(service.id)
      await deleteService(service.id)
      setServices(prev => prev.filter(s => s.id !== service.id))
      toast.success(t('services.action.delete'))
    } catch (err) {
      toast.error(err instanceof Error ? err.message : 'Failed to delete')
    } finally {
      setBusyId(null)
    }
  }

  const handleSubmit = async (payload: ServicePayload) => {
    try {
      setSaving(true)
      if (isEditingService(editing)) await patchService(editing.id, payload)
      else await createService(payload)
      await load()
      setEditing(null)
      toast.success(t('common.save'))
    } catch (err) {
      toast.error(err instanceof Error ? err.message : 'Failed to save')
    } finally {
      setSaving(false)
    }
  }

  return (
    <>
      <ServicesHeader onCreate={openCreate} />
      <ServicesSearch query={query} onQueryChange={setQuery} />

      {error && <ServicesError error={error} />}
      {!error && loading && showSkeleton && <ServicesSkeleton />}
      {!error && !loading && services.length === 0 && <EmptyServicesState onCreate={openCreate} />}
      {!error && !loading && services.length > 0 && (
        <ServicesGrid
          services={visible}
          filters={filters}
          activeFilter={tab}
          isEmptySearch={isEmptySearch}
          busyId={busyId}
          onFilterChange={setTab}
          onEdit={setEditing}
          onDelete={onDelete}
        />
      )}

      <Modal open={editing !== null} onClose={() => !saving && setEditing(null)} title={modalTitle}>
        {editing !== null && (
          <ServiceForm
            service={isEditingService(editing) ? editing : null}
            onSubmit={handleSubmit}
            onCancel={() => setEditing(null)}
            saving={saving}
          />
        )}
      </Modal>
    </>
  )
}
QUALITY_REFACTOR_FILE

write_file 'src/pages/booking-detail/BookingCustomerCard.tsx' <<'QUALITY_REFACTOR_FILE'
import { Avatar, Card, LabelMono } from '../../components/UI'
import { useT } from '../../i18n/SettingsContext'
import type { Booking } from '../../types'

export default function BookingCustomerCard({ booking }: { booking: Booking }) {
  const t = useT()

  return (
    <Card className="mb-6">
      <LabelMono>{t('bookings.detail.section.customer')}</LabelMono>
      <div className="flex flex-gap-3 mt-4" style={{ alignItems: 'center' }}>
        <Avatar initials={booking.initials || '?'} size={40} />
        <div>
          <div style={{ fontWeight: 600 }}>{booking.withName || '—'}</div>
          <div className="text-muted" style={{ fontSize: 13 }}>{booking.customerEmail}</div>
          {booking.customerPhone && (
            <div className="text-muted mono" style={{ fontSize: 13 }}>{booking.customerPhone}</div>
          )}
        </div>
      </div>
    </Card>
  )
}
QUALITY_REFACTOR_FILE

write_file 'src/pages/booking-detail/BookingDetailActions.tsx' <<'QUALITY_REFACTOR_FILE'
import { Button, Divider } from '../../components/UI'
import { useT } from '../../i18n/SettingsContext'
import { downloadIcs } from '../../utils/ics'
import type { Booking } from '../../types'
import { getBookingRef } from './bookingDetailUtils'

interface BookingDetailActionsProps {
  booking: Booking
  busy: boolean
  onCancel: () => void
  onDelete: () => void
}

export default function BookingDetailActions({ booking, busy, onCancel, onDelete }: BookingDetailActionsProps) {
  const t = useT()
  const isCancelled = booking.status === 'cancelled'
  const ref = getBookingRef(booking.id)

  return (
    <>
      <Divider />

      <div className="flex flex-gap-3 mt-4">
        <Button onClick={() => downloadIcs(booking, `slottr-${ref}.ics`)} disabled={busy}>
          {t('conf.btn.addToCal')}
        </Button>
        {!isCancelled && (
          <Button variant="ghost" onClick={onCancel} disabled={busy} style={{ color: 'var(--warning)' }}>
            {busy ? t('bookings.cancelling') : t('bookings.action.cancel')}
          </Button>
        )}
        <Button variant="ghost" onClick={onDelete} disabled={busy} style={{ color: 'var(--danger)' }}>
          {busy ? t('bookings.deleting') : t('bookings.action.delete')}
        </Button>
      </div>
    </>
  )
}
QUALITY_REFACTOR_FILE

write_file 'src/pages/booking-detail/BookingDetailHeader.tsx' <<'QUALITY_REFACTOR_FILE'
import { Pill } from '../../components/UI'
import { useT } from '../../i18n/SettingsContext'
import type { Booking } from '../../types'
import { getBookingRef, getStatusTone } from './bookingDetailUtils'

interface BookingDetailHeaderProps {
  booking: Booking
  onBack: () => void
}

export default function BookingDetailHeader({ booking, onBack }: BookingDetailHeaderProps) {
  const t = useT()

  return (
    <>
      <button onClick={onBack} className="btn-text" style={{ fontSize: 13, cursor: 'pointer' }}>
        {t('bookings.detail.backToList')}
      </button>

      <div className="flex-between mt-4 mb-2" style={{ alignItems: 'flex-start' }}>
        <h1>{booking.service}</h1>
        <Pill tone={getStatusTone(booking.status)}>{t(`status.${booking.status}`)}</Pill>
      </div>
      <p className="subtitle mb-8 mono">#{getBookingRef(booking.id)}</p>
    </>
  )
}
QUALITY_REFACTOR_FILE

write_file 'src/pages/booking-detail/BookingDetailState.tsx' <<'QUALITY_REFACTOR_FILE'
import EmptyState from '../../components/EmptyState'
import { Skeleton } from '../../components/Skeleton'
import { useT } from '../../i18n/SettingsContext'

export function BookingDetailSkeleton() {
  return (
    <div style={{ maxWidth: 720 }}>
      <Skeleton width={80} height={14} style={{ marginBottom: 16 }} />
      <Skeleton width="50%" height={32} style={{ marginBottom: 8 }} />
      <Skeleton width={120} height={14} style={{ marginBottom: 32 }} />
      <Skeleton width="100%" height={120} radius={14} style={{ marginBottom: 24 }} />
      <Skeleton width="100%" height={80} radius={14} style={{ marginBottom: 24 }} />
      <Skeleton width="100%" height={80} radius={14} />
    </div>
  )
}

export function BookingDetailNotFound({ title, onBack }: { title: string; onBack: () => void }) {
  const t = useT()

  return (
    <>
      <button onClick={onBack} className="btn-text" style={{ fontSize: 13, cursor: 'pointer' }}>
        {t('bookings.detail.backToList')}
      </button>
      <EmptyState illustration="calendar" title={title} />
    </>
  )
}
QUALITY_REFACTOR_FILE

write_file 'src/pages/booking-detail/BookingNotesCard.tsx' <<'QUALITY_REFACTOR_FILE'
import { Card, LabelMono } from '../../components/UI'
import { useT } from '../../i18n/SettingsContext'
import type { Booking } from '../../types'

export default function BookingNotesCard({ booking }: { booking: Booking }) {
  const t = useT()

  return (
    <Card className="mb-6">
      <LabelMono>{t('bookings.detail.section.notes')}</LabelMono>
      <div
        className={booking.notes ? '' : 'text-subtle'}
        style={{ marginTop: 8, whiteSpace: 'pre-wrap', fontSize: 14 }}
      >
        {booking.notes || t('bookings.detail.noNotes')}
      </div>
    </Card>
  )
}
QUALITY_REFACTOR_FILE

write_file 'src/pages/booking-detail/BookingSummaryCard.tsx' <<'QUALITY_REFACTOR_FILE'
import { Card, LabelMono } from '../../components/UI'
import { useT, useSettings } from '../../i18n/SettingsContext'
import type { Booking } from '../../types'
import { formatBookingDate, getBookingTimeRange } from './bookingDetailUtils'

export default function BookingSummaryCard({ booking }: { booking: Booking }) {
  const t = useT()
  const { lang } = useSettings()

  return (
    <Card className="mb-6">
      <div className="grid grid-2">
        <div>
          <LabelMono>{t('conf.field.date')}</LabelMono>
          <div style={{ fontWeight: 600, marginTop: 8 }}>{formatBookingDate(booking.dateISO, lang)}</div>
        </div>
        <div>
          <LabelMono>{t('conf.field.time')}</LabelMono>
          <div className="mono" style={{ marginTop: 8 }}>
            {getBookingTimeRange(booking)} ({booking.durationMin || 60} {t('services.minutes')})
          </div>
        </div>
        <div>
          <LabelMono>{t('conf.field.location')}</LabelMono>
          <div style={{ marginTop: 8 }}>{t('conf.location')}</div>
        </div>
        <div>
          <LabelMono>{t('conf.field.total')}</LabelMono>
          <div className="text-accent mono" style={{ marginTop: 8, fontWeight: 600, fontSize: 16 }}>
            ${Number(booking.total || 0).toFixed(2)}
          </div>
        </div>
      </div>
    </Card>
  )
}
QUALITY_REFACTOR_FILE

write_file 'src/pages/booking-detail/bookingDetailUtils.ts' <<'QUALITY_REFACTOR_FILE'
import type { Booking, Lang } from '../../types'

export function formatBookingDate(iso: string | undefined, lang: Lang): string {
  if (!iso) return ''
  const [y, m, d] = iso.split('-').map(Number)
  const date = new Date(y, m - 1, d)
  return date.toLocaleDateString(lang === 'ru' ? 'ru-RU' : 'en-US', {
    weekday: 'short', month: 'long', day: 'numeric', year: 'numeric',
  })
}

export function getBookingRef(id: Booking['id']): string {
  return `SLT-${String(id).padStart(4, '0')}`
}

export function getBookingTimeRange(booking: Booking): string {
  return booking.endTime ? `${booking.time} – ${booking.endTime}` : booking.time
}

export function getStatusTone(status: Booking['status']): 'success' | 'danger' | 'accent' {
  if (status === 'cancelled') return 'danger'
  if (status === 'confirmed') return 'success'
  return 'accent'
}
QUALITY_REFACTOR_FILE

write_file 'src/pages/booking/BookingHeader.tsx' <<'QUALITY_REFACTOR_FILE'
import { Link } from 'react-router-dom'
import { useT } from '../../i18n/SettingsContext'
import type { Step } from './bookingTypes'

interface BookingHeaderProps {
  step: Step
}

export default function BookingHeader({ step }: BookingHeaderProps) {
  const t = useT()

  return (
    <>
      <Link to="/dashboard" className="btn-text">{t('booking.backToDashboard')}</Link>
      <h1 className="mt-4 mb-2">{t('booking.title')}</h1>
      <p className="subtitle mb-8">{t('booking.subtitle')}</p>

      <div className="stepper">
        <div className={`step ${step === 1 ? 'active' : 'done'}`}><span className="num">1</span> {t('booking.step.service')}</div>
        <span className="sep">·</span>
        <div className={`step ${step === 2 ? 'active' : step > 2 ? 'done' : ''}`}><span className="num">2</span> {t('booking.step.dateTime')}</div>
        <span className="sep">·</span>
        <div className={`step ${step === 3 ? 'active' : step > 3 ? 'done' : ''}`}><span className="num">3</span> {t('booking.step.details')}</div>
        <span className="sep">·</span>
        <div className={`step ${step === 4 ? 'active' : ''}`}><span className="num">4</span> {t('booking.step.confirm')}</div>
      </div>
    </>
  )
}
QUALITY_REFACTOR_FILE

write_file 'src/pages/booking/ConfirmStep.tsx' <<'QUALITY_REFACTOR_FILE'
import type { ReactNode } from 'react'
import { Button, Card, Divider, LabelMono } from '../../components/UI'
import { loc } from '../../data/mock'
import { useT, useSettings } from '../../i18n/SettingsContext'
import type { Service } from '../../types'
import type { CustomerForm } from './bookingTypes'
import { addMinutesHHMM } from './bookingUtils'

interface ConfirmStepProps {
  selectedService: Service | null
  customer: CustomerForm
  dateLabel: string
  time: string
  termsAccepted: boolean
  termsError: boolean
  error: string
  saving: boolean
  onTermsChange: (accepted: boolean) => void
  onBack: () => void
  onConfirm: () => void
}

export default function ConfirmStep({
  selectedService,
  customer,
  dateLabel,
  time,
  termsAccepted,
  termsError,
  error,
  saving,
  onTermsChange,
  onBack,
  onConfirm,
}: ConfirmStepProps) {
  const t = useT()
  const { lang } = useSettings()

  return (
    <>
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
            onChange={(e) => onTermsChange(e.target.checked)}
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
          <Button variant="ghost" onClick={onBack} disabled={saving}>{t('common.back')}</Button>
          <Button onClick={onConfirm} disabled={saving}>
            {saving ? t('booking.saving') : t('booking.confirm.btn')}
          </Button>
        </div>
      </div>
    </>
  )
}

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
QUALITY_REFACTOR_FILE

write_file 'src/pages/booking/DateTimeStep.tsx' <<'QUALITY_REFACTOR_FILE'
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
QUALITY_REFACTOR_FILE

write_file 'src/pages/booking/DetailsForm.tsx' <<'QUALITY_REFACTOR_FILE'
import { useState, type ChangeEvent, type FormEvent, type ReactNode } from 'react'
import { Button, Field } from '../../components/UI'
import { useT } from '../../i18n/SettingsContext'
import type { CustomerForm, DetailsErrors } from './bookingTypes'
import { validateDetails } from './bookingValidation'

interface DetailsFormProps {
  defaultValues: CustomerForm
  onSubmit: (data: CustomerForm) => void
  onBack: () => void
}

export default function DetailsForm({ defaultValues, onSubmit, onBack }: DetailsFormProps) {
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
QUALITY_REFACTOR_FILE

write_file 'src/pages/booking/ServiceStep.tsx' <<'QUALITY_REFACTOR_FILE'
import { Link } from 'react-router-dom'
import { Button, Card, Pill } from '../../components/UI'
import { IconSearch } from '../../components/Icons'
import EmptyState from '../../components/EmptyState'
import { SkeletonCardGrid } from '../../components/Skeleton'
import { loc } from '../../data/mock'
import { useT, useSettings } from '../../i18n/SettingsContext'
import type { Service } from '../../types'
import { matchesServiceQuery } from './bookingUtils'

interface ServiceStepProps {
  services: Service[]
  loading: boolean
  showSkeleton: boolean
  selectedServiceId: string | null
  selectedTag: string
  query: string
  onTagChange: (tag: string) => void
  onQueryChange: (query: string) => void
  onPickService: (id: string) => void
}

export default function ServiceStep({
  services,
  loading,
  showSkeleton,
  selectedServiceId,
  selectedTag,
  query,
  onTagChange,
  onQueryChange,
  onPickService,
}: ServiceStepProps) {
  const t = useT()
  const { lang } = useSettings()

  const matchedAll = services.filter(s => matchesServiceQuery(s, query, lang))
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
  if (selectedTag !== 'all') visible = visible.filter(s => s.tag?.en === selectedTag)
  if (query) visible = visible.filter(s => matchesServiceQuery(s, query, lang))

  const isEmptySearch = !loading && services.length > 0 && visible.length === 0

  return (
    <>
      <h3 className="mb-2">{t('booking.chooseService')}</h3>
      <p className="text-muted mb-6">{t('booking.chooseServiceSub')}</p>

      {loading && showSkeleton && <SkeletonCardGrid />}

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
              value={query}
              onChange={(e) => onQueryChange(e.target.value)}
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
                  className={`filter-item ${selectedTag === f.value ? 'active' : ''}`}
                  onClick={() => onTagChange(f.value)}
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
QUALITY_REFACTOR_FILE

write_file 'src/pages/booking/bookingTypes.ts' <<'QUALITY_REFACTOR_FILE'
export type Step = 1 | 2 | 3 | 4

export interface CustomerForm {
  name: string
  email: string
  phone: string
  notes: string
}

export type DetailsErrors = Partial<Record<keyof CustomerForm, string>>
QUALITY_REFACTOR_FILE

write_file 'src/pages/booking/bookingUtils.ts' <<'QUALITY_REFACTOR_FILE'
import { loc } from '../../data/mock'
import type { Booking, Lang, Service } from '../../types'

export function toISODate(d: Date): string {
  const yyyy = d.getFullYear()
  const mm = String(d.getMonth() + 1).padStart(2, '0')
  const dd = String(d.getDate()).padStart(2, '0')
  return `${yyyy}-${mm}-${dd}`
}

export function addMinutesHHMM(time: string, minutesToAdd: number): string {
  const [hStr, mStr] = time.split(':')
  const total = Number(hStr) * 60 + Number(mStr) + minutesToAdd
  const h = String(Math.floor(total / 60) % 24).padStart(2, '0')
  const m = String(total % 60).padStart(2, '0')
  return `${h}:${m}`
}

// "10:00" -> 600 (minutes since 00:00)
export function toMinutes(time: string): number {
  const [h, m] = time.split(':').map(Number)
  return h * 60 + m
}

// "Anna Smith" -> "AS"
export function initialsFrom(name: string): string {
  if (!name) return '?'
  return name.trim().split(/\s+/).slice(0, 2).map(w => w[0]?.toUpperCase() || '').join('') || '?'
}

export function matchesServiceQuery(s: Service, q: string, lang: Lang): boolean {
  if (!q) return true
  const haystack = [
    loc(s.name, lang), loc(s.description, lang), loc(s.tag, lang),
    s.name?.en, s.name?.ru, s.description?.en, s.description?.ru, s.tag?.en, s.tag?.ru,
  ].filter(Boolean).join(' ').toLowerCase()
  return haystack.includes(q.toLowerCase())
}

export function getBookingEventDates(bookings: Booking[]): Date[] {
  const dates: Date[] = []
  for (const b of bookings) {
    if (!b.dateISO || b.status === 'cancelled') continue
    const [y, m, d] = b.dateISO.split('-').map(Number)
    if (!y || !m || !d) continue
    dates.push(new Date(y, m - 1, d))
  }
  return dates
}

export function isDateInPast(date: Date): boolean {
  const today = new Date()
  const todayMid = new Date(today.getFullYear(), today.getMonth(), today.getDate())
  const selectedMid = new Date(date.getFullYear(), date.getMonth(), date.getDate())
  return selectedMid < todayMid
}
QUALITY_REFACTOR_FILE

write_file 'src/pages/booking/bookingValidation.ts' <<'QUALITY_REFACTOR_FILE'
import type { TKey } from '../../i18n/translations'
import type { CustomerForm, DetailsErrors } from './bookingTypes'

const EMAIL_RE = /^[^@\s]+@[^@\s]+\.[^@\s]+$/
const PHONE_RE = /^[+\d\s()\-]{6,}$/

type TFn = (key: TKey, params?: Record<string, string | number>) => string

export function validateDetails(values: CustomerForm, t: TFn): DetailsErrors {
  const errors: DetailsErrors = {}
  if (!values.name.trim()) errors.name = t('validation.required')
  if (!values.email.trim()) errors.email = t('validation.required')
  else if (!EMAIL_RE.test(values.email.trim())) errors.email = t('validation.email')
  if (values.phone.trim() && !PHONE_RE.test(values.phone.trim())) errors.phone = t('validation.phone')
  return errors
}
QUALITY_REFACTOR_FILE

write_file 'src/pages/bookings/BookingsFilters.tsx' <<'QUALITY_REFACTOR_FILE'
import { Tabs, type TabItem } from '../../components/UI'
import { IconSearch } from '../../components/Icons'
import { useT } from '../../i18n/SettingsContext'
import type { StatusTab } from './bookingsTypes'

interface BookingsFiltersProps {
  tabs: TabItem<StatusTab>[]
  status: StatusTab
  query: string
  onStatusChange: (status: StatusTab) => void
  onQueryChange: (query: string) => void
}

export default function BookingsFilters({
  tabs,
  status,
  query,
  onStatusChange,
  onQueryChange,
}: BookingsFiltersProps) {
  const t = useT()

  return (
    <>
      <Tabs items={tabs} value={status} onChange={onStatusChange} />
      <div
        className="mb-4"
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
          value={query}
          onChange={(e) => onQueryChange(e.target.value)}
          placeholder={t('bookings.search.placeholder')}
          style={{
            flex: 1, border: 'none', outline: 'none', background: 'none',
            color: 'var(--text)', fontSize: 13,
          }}
        />
      </div>
    </>
  )
}
QUALITY_REFACTOR_FILE

write_file 'src/pages/bookings/BookingsHeader.tsx' <<'QUALITY_REFACTOR_FILE'
import { Button } from '../../components/UI'
import { useT } from '../../i18n/SettingsContext'

interface BookingsHeaderProps {
  loading: boolean
  onRefresh: () => void
}

export default function BookingsHeader({ loading, onRefresh }: BookingsHeaderProps) {
  const t = useT()

  return (
    <div className="flex-between mb-6">
      <div>
        <h1>{t('bookings.title')}</h1>
        <p className="subtitle mt-2">{t('bookings.subtitle')}</p>
      </div>
      <div className="flex flex-gap-2">
        <Button variant="ghost" size="sm" onClick={onRefresh} disabled={loading}>
          {loading ? t('common.loading') : t('common.refresh')}
        </Button>
        <Button as="link" to="/booking" size="sm">+ {t('nav.newBooking')}</Button>
      </div>
    </div>
  )
}
QUALITY_REFACTOR_FILE

write_file 'src/pages/bookings/BookingsState.tsx' <<'QUALITY_REFACTOR_FILE'
import { Button } from '../../components/UI'
import EmptyState from '../../components/EmptyState'
import { SkeletonTableRow } from '../../components/Skeleton'
import { useT } from '../../i18n/SettingsContext'
import { BookingsTableHead } from './BookingsTable'
import type { StatusTab } from './bookingsTypes'

interface BookingsErrorProps {
  error: string
}

export function BookingsError({ error }: BookingsErrorProps) {
  return (
    <div className="mb-4" style={{
      padding: '12px 16px', border: '1px solid rgba(248,113,113,0.32)',
      background: 'rgba(248,113,113,0.12)', color: 'var(--danger)',
      borderRadius: 'var(--r-md)', fontSize: 13,
    }}>{error}</div>
  )
}

export function BookingsSkeleton() {
  return (
    <table className="table">
      <BookingsTableHead />
      <tbody>
        {Array.from({ length: 5 }, (_, i) => <SkeletonTableRow key={i} cols={7} />)}
      </tbody>
    </table>
  )
}

export function FirstRunEmptyState() {
  const t = useT()

  return (
    <EmptyState
      illustration="calendar"
      title={t('bookings.empty.first')}
      description={t('bookings.empty.first.desc')}
      action={
        <div className="flex flex-gap-2">
          <Button as="link" to="/booking">+ {t('nav.newBooking')}</Button>
          <Button as="link" to="/services" variant="ghost">{t('services.add')}</Button>
        </div>
      }
    />
  )
}

export function EmptyBookingsState({ status, query }: { status: StatusTab; query: string }) {
  const t = useT()

  if (query.trim()) {
    return <EmptyState illustration="search" title={t('bookings.search.empty')} />
  }

  const titleMap: Record<StatusTab, string> = {
    upcoming: t('bookings.empty.upcoming'),
    past: t('bookings.empty.past'),
    cancelled: t('bookings.empty.cancelled'),
  }
  const descMap: Record<StatusTab, string> = {
    upcoming: t('bookings.empty.upcoming.desc'),
    past: t('bookings.empty.past.desc'),
    cancelled: t('bookings.empty.cancelled.desc'),
  }

  return (
    <EmptyState
      illustration="calendar"
      title={titleMap[status]}
      description={descMap[status]}
      action={status === 'upcoming'
        ? <Button as="link" to="/booking">+ {t('nav.newBooking')}</Button>
        : undefined}
    />
  )
}
QUALITY_REFACTOR_FILE

write_file 'src/pages/bookings/BookingsTable.tsx' <<'QUALITY_REFACTOR_FILE'
import { Link } from 'react-router-dom'
import { Avatar, Pill } from '../../components/UI'
import { useT, useSettings } from '../../i18n/SettingsContext'
import type { Booking } from '../../types'
import type { AnnotatedBooking, StatusTab } from './bookingsTypes'
import { formatDateShort } from './bookingsUtils'

interface BookingsTableProps {
  items: AnnotatedBooking[]
  status: StatusTab
  busyId: string | null
  onEdit: (booking: Booking) => void
  onCancel: (booking: Booking) => void
  onDelete: (booking: Booking) => void
}

export default function BookingsTable({
  items,
  status,
  busyId,
  onEdit,
  onCancel,
  onDelete,
}: BookingsTableProps) {
  const t = useT()
  const { lang } = useSettings()

  return (
    <table className="table">
      <BookingsTableHead actions />
      <tbody>
        {items.map(({ b }) => {
          const isBusy = busyId === b.id
          const showCancel = status === 'upcoming'

          return (
            <tr key={b.id}>
              <td className="mono">{formatDateShort(b.dateISO, lang)}</td>
              <td className="mono">{b.time}</td>
              <td>{b.service}</td>
              <td>
                <div className="flex flex-gap-2" style={{ alignItems: 'center' }}>
                  <Avatar initials={b.initials || '?'} size={24} />
                  {b.withName || '—'}
                </div>
              </td>
              <td>
                <Pill tone={
                  b.status === 'confirmed' ? 'success' :
                  b.status === 'cancelled' ? 'danger' : 'accent'
                }>
                  {t(`status.${b.status}`)}
                </Pill>
              </td>
              <td className="mono">${b.total}</td>
              <td style={{ textAlign: 'right' }}>
                <div className="flex flex-gap-2" style={{ justifyContent: 'flex-end' }}>
                  <Link to={`/bookings/${b.id}`} className="btn-text">{t('action.view')}</Link>
                  {showCancel && (
                    <>
                      <button
                        onClick={() => onEdit(b)}
                        disabled={isBusy}
                        className="btn-text"
                        style={{ cursor: 'pointer' }}
                      >
                        {t('bookings.action.edit')}
                      </button>
                      <button
                        onClick={() => onCancel(b)}
                        disabled={isBusy}
                        className="btn-text"
                        style={{ color: 'var(--warning)', cursor: 'pointer' }}
                      >
                        {isBusy ? t('bookings.cancelling') : t('bookings.action.cancel')}
                      </button>
                    </>
                  )}
                  <button
                    onClick={() => onDelete(b)}
                    disabled={isBusy}
                    className="btn-text"
                    style={{ color: 'var(--danger)', cursor: 'pointer' }}
                  >
                    {isBusy ? t('bookings.deleting') : t('bookings.action.delete')}
                  </button>
                </div>
              </td>
            </tr>
          )
        })}
      </tbody>
    </table>
  )
}

export function BookingsTableHead({ actions = false }: { actions?: boolean }) {
  const t = useT()

  return (
    <thead>
      <tr>
        <th>{t('table.date')}</th><th>{t('table.time')}</th>
        <th>{t('table.service')}</th><th>{t('table.with')}</th>
        <th>{t('table.status')}</th><th>{t('table.total')}</th>
        <th style={actions ? { textAlign: 'right' } : undefined}>{actions ? t('table.actions') : undefined}</th>
      </tr>
    </thead>
  )
}
QUALITY_REFACTOR_FILE

write_file 'src/pages/bookings/bookingsTypes.ts' <<'QUALITY_REFACTOR_FILE'
import type { Booking } from '../../types'

export type StatusTab = 'upcoming' | 'past' | 'cancelled'

export interface AnnotatedBooking {
  b: Booking
}

export interface BookingGroups {
  upcoming: AnnotatedBooking[]
  past: AnnotatedBooking[]
  cancelled: AnnotatedBooking[]
}
QUALITY_REFACTOR_FILE

write_file 'src/pages/bookings/bookingsUtils.ts' <<'QUALITY_REFACTOR_FILE'
import type { Booking, Lang } from '../../types'
import type { AnnotatedBooking, BookingGroups, StatusTab } from './bookingsTypes'

export function formatDateShort(iso: string | undefined, lang: Lang): string {
  if (!iso) return '—'
  const [y, m, d] = iso.split('-').map(Number)
  const date = new Date(y, m - 1, d)
  return date.toLocaleDateString(lang === 'ru' ? 'ru-RU' : 'en-US', { month: 'short', day: 'numeric' })
}

export function toISODate(d: Date): string {
  const yyyy = d.getFullYear()
  const mm = String(d.getMonth() + 1).padStart(2, '0')
  const dd = String(d.getDate()).padStart(2, '0')
  return `${yyyy}-${mm}-${dd}`
}

export function sortBookings(bookings: Booking[]): Booking[] {
  return [...bookings].sort((a, b) => {
    const byDate = (a.dateISO || '').localeCompare(b.dateISO || '')
    if (byDate !== 0) return byDate
    return (a.time || '').localeCompare(b.time || '')
  })
}

export function annotateBookings(bookings: Booking[]): AnnotatedBooking[] {
  return bookings.map(b => ({ b }))
}

export function groupBookingsByStatus(annotated: AnnotatedBooking[], todayISO = toISODate(new Date())): BookingGroups {
  const upcoming: AnnotatedBooking[] = []
  const past: AnnotatedBooking[] = []
  const cancelled: AnnotatedBooking[] = []

  for (const x of annotated) {
    if (x.b.status === 'cancelled') cancelled.push(x)
    else if ((x.b.dateISO || '') >= todayISO) upcoming.push(x)
    else past.push(x)
  }

  return { upcoming, past, cancelled }
}

export function filterBookings(
  groups: BookingGroups,
  status: StatusTab,
  query: string,
): AnnotatedBooking[] {
  const list = groups[status] || []
  const q = query.trim().toLowerCase()
  if (!q) return list

  return list.filter(({ b }) =>
    (b.withName || '').toLowerCase().includes(q) ||
    (b.service || '').toLowerCase().includes(q) ||
    (b.customerEmail || '').toLowerCase().includes(q) ||
    (b.dateISO || '').includes(q),
  )
}

export function addMinutesHHMM(time: string, minutesToAdd: number): string {
  const [hStr, mStr] = time.split(':')
  const total = Number(hStr) * 60 + Number(mStr) + minutesToAdd
  return `${String(Math.floor(total / 60) % 24).padStart(2, '0')}:${String(total % 60).padStart(2, '0')}`
}
QUALITY_REFACTOR_FILE

write_file 'src/pages/dashboard/DashboardHeader.tsx' <<'QUALITY_REFACTOR_FILE'
import { useT } from '../../i18n/SettingsContext'

interface DashboardHeaderProps {
  greetingName: string
  todayCount: number
}

export default function DashboardHeader({ greetingName, todayCount }: DashboardHeaderProps) {
  const t = useT()

  return (
    <div className="mb-6">
      <h1>{t('dashboard.greeting', { name: greetingName })}</h1>
      <p className="subtitle mt-2">{t('dashboard.subtitle', { n: todayCount })}</p>
    </div>
  )
}
QUALITY_REFACTOR_FILE

write_file 'src/pages/dashboard/DashboardStatsGrid.tsx' <<'QUALITY_REFACTOR_FILE'
import { Stat } from '../../components/UI'
import { SkeletonStat } from '../../components/Skeleton'
import { useT } from '../../i18n/SettingsContext'
import type { DashboardDelta, DashboardStats } from './dashboardUtils'

interface DashboardStatsGridProps {
  stats: DashboardStats
  loading: boolean
  showSkeleton: boolean
}

export default function DashboardStatsGrid({ stats, loading, showSkeleton }: DashboardStatsGridProps) {
  const t = useT()

  const renderDelta = (d: DashboardDelta | null, key: 'vsYesterday' | 'vsLastWeek' | 'vsLastMonth') => {
    if (!d) return undefined
    return t(`dashboard.stat.delta.${key}`, { n: d.value })
  }

  return (
    <div className="grid grid-4 mb-8">
      {loading && showSkeleton ? (
        <>
          <SkeletonStat /><SkeletonStat /><SkeletonStat /><SkeletonStat />
        </>
      ) : (
        <>
          <Stat
            label={t('dashboard.stat.today')}
            value={loading ? '—' : stats.todayCount}
            delta={renderDelta(stats.todayDelta, 'vsYesterday')}
            down={stats.todayDelta?.down}
          />
          <Stat
            label={t('dashboard.stat.week')}
            value={loading ? '—' : stats.weekCount}
            delta={renderDelta(stats.weekDelta, 'vsLastWeek')}
            down={stats.weekDelta?.down}
          />
          <Stat
            label={t('dashboard.stat.revenue')}
            value={loading ? '—' : `$${stats.monthRevenue.toLocaleString('en-US')}`}
            delta={renderDelta(stats.monthRevenueDelta, 'vsLastMonth')}
            down={stats.monthRevenueDelta?.down}
          />
          <Stat
            label={t('dashboard.stat.cancellations')}
            value={loading ? '—' : stats.monthCancellations}
            delta={renderDelta(stats.monthCancellationsDelta, 'vsLastMonth')}
            // For cancellations, "more" is bad — flip the colour intuitively.
            down={stats.monthCancellationsDelta ? !stats.monthCancellationsDelta.down && stats.monthCancellationsDelta.value !== '0' : undefined}
          />
        </>
      )}
    </div>
  )
}
QUALITY_REFACTOR_FILE

write_file 'src/pages/dashboard/UpcomingBookings.tsx' <<'QUALITY_REFACTOR_FILE'
import { Link } from 'react-router-dom'
import { Button, Pill, Avatar } from '../../components/UI'
import EmptyState from '../../components/EmptyState'
import { SkeletonTableRow } from '../../components/Skeleton'
import { useT } from '../../i18n/SettingsContext'
import type { Booking } from '../../types'

interface UpcomingBookingsProps {
  bookings: Booking[]
  loading: boolean
  error: string | null
  showSkeleton: boolean
}

export default function UpcomingBookings({ bookings, loading, error, showSkeleton }: UpcomingBookingsProps) {
  const t = useT()

  return (
    <>
      <h2 className="mb-4">{t('dashboard.upcomingNext')}</h2>

      {!error && loading && showSkeleton && (
        <table className="table">
          <TableHead />
          <tbody>
            {Array.from({ length: 3 }, (_, i) => <SkeletonTableRow key={i} cols={6} />)}
          </tbody>
        </table>
      )}

      {!error && !loading && bookings.length === 0 && (
        <EmptyState
          illustration="calendar"
          title={t('dashboard.empty')}
          action={<Button as="link" to="/booking">+ {t('nav.newBooking')}</Button>}
        />
      )}

      {!error && !loading && bookings.length > 0 && (
        <table className="table">
          <TableHead />
          <tbody>
            {bookings.map((b) => (
              <tr key={b.id}>
                <td className="mono">{b.dateISO}</td>
                <td className="mono">{b.time}</td>
                <td>{b.service}</td>
                <td>
                  <div className="flex flex-gap-2" style={{ alignItems: 'center' }}>
                    <Avatar initials={b.initials || '?'} size={24} />
                    {b.withName || '—'}
                  </div>
                </td>
                <td><Pill tone={b.status === 'confirmed' ? 'success' : 'accent'}>{t(`status.${b.status}`)}</Pill></td>
                <td><Link to={`/bookings/${b.id}`} className="btn-text">{t('action.view.arrow')}</Link></td>
              </tr>
            ))}
          </tbody>
        </table>
      )}
    </>
  )
}

function TableHead() {
  const t = useT()

  return (
    <thead>
      <tr>
        <th>{t('table.date')}</th>
        <th>{t('table.time')}</th>
        <th>{t('table.service')}</th>
        <th>{t('table.with')}</th>
        <th>{t('table.status')}</th>
        <th />
      </tr>
    </thead>
  )
}
QUALITY_REFACTOR_FILE

write_file 'src/pages/dashboard/WeekCalendar.tsx' <<'QUALITY_REFACTOR_FILE'
import { Link } from 'react-router-dom'
import { Button } from '../../components/UI'
import { useT, useSettings } from '../../i18n/SettingsContext'
import { isSameDay } from '../../utils/date'
import type { Booking, Lang } from '../../types'
import { getEventGeometry, type HourBounds } from './dashboardUtils'

const DOW_LABELS: Record<Lang, string[]> = {
  en: ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'],
  ru: ['ПН', 'ВТ', 'СР', 'ЧТ', 'ПТ', 'СБ', 'ВС'],
}

interface WeekCalendarProps {
  days: Date[]
  hours: string[]
  today: Date
  isCurrentWeek: boolean
  hourBounds: HourBounds
  weekEventsByDay: Record<number, Booking[]>
  onPrevWeek: () => void
  onToday: () => void
  onNextWeek: () => void
}

export default function WeekCalendar({
  days,
  hours,
  today,
  isCurrentWeek,
  hourBounds,
  weekEventsByDay,
  onPrevWeek,
  onToday,
  onNextWeek,
}: WeekCalendarProps) {
  const t = useT()
  const { lang } = useSettings()

  return (
    <>
      <div className="flex-between mb-4">
        <h2>{t('dashboard.thisWeek')}</h2>
        <div className="flex flex-gap-2">
          <Button variant="ghost" size="sm" onClick={onPrevWeek}>{t('dashboard.prev')}</Button>
          <Button variant="ghost" size="sm" onClick={onToday} disabled={isCurrentWeek}>{t('dashboard.today')}</Button>
          <Button variant="ghost" size="sm" onClick={onNextWeek}>{t('dashboard.next')}</Button>
        </div>
      </div>

      <div className="week mb-8">
        <div className="week-head">
          <div className="col" />
          {days.map((d, i) => (
            <div className={`col ${isSameDay(d, today) ? 'today' : ''}`} key={i}>
              {DOW_LABELS[lang][i]}
              <div className="day-num">{d.getDate()}</div>
            </div>
          ))}
        </div>
        <div className="week-body">
          <div className="hour-col">
            {hours.map(h => <div className="hour" key={h}>{h}</div>)}
          </div>
          {days.map((_, i) => (
            <div className="day-col" key={i}>
              {hours.map((_, j) => <div className="slot" key={j} />)}
              {(weekEventsByDay[i] || []).map((b) => {
                const { top, height } = getEventGeometry(b, hourBounds)
                return (
                  <Link
                    to={`/bookings/${b.id}`}
                    key={b.id}
                    className="event"
                    style={{ top, height, textDecoration: 'none' }}
                  >
                    <div className="title">{b.service}</div>
                    <div className="time">
                      {b.time}{b.endTime ? ` – ${b.endTime}` : ''}
                    </div>
                  </Link>
                )
              })}
            </div>
          ))}
        </div>
      </div>
    </>
  )
}
QUALITY_REFACTOR_FILE

write_file 'src/pages/dashboard/dashboardUtils.ts' <<'QUALITY_REFACTOR_FILE'
import {
  addDays, endOfMonth, endOfWeek, isWithinRange,
  startOfMonth, startOfWeek, timeToMinutes, toISODate,
} from '../../utils/date'
import type { Booking } from '../../types'

export const DEFAULT_HOUR_START = 9
export const DEFAULT_HOUR_END = 18
export const HOUR_HEIGHT = 56 // px, matches CSS .slot height

export interface DashboardDelta {
  value: string
  down: boolean
}

export interface DashboardStats {
  todayCount: number
  todayDelta: DashboardDelta | null
  weekCount: number
  weekDelta: DashboardDelta | null
  monthRevenue: number
  monthRevenueDelta: DashboardDelta | null
  monthCancellations: number
  monthCancellationsDelta: DashboardDelta | null
}

export interface HourBounds {
  startHour: number
  endHour: number
}

export function formatDiff(curr: number, prev: number): DashboardDelta | null {
  const diff = curr - prev
  if (diff === 0 && curr === 0) return null
  const sign = diff > 0 ? '+' : diff < 0 ? '−' : ''
  return { value: `${sign}${Math.abs(diff)}`, down: diff < 0 }
}

export function formatMoneyDiff(curr: number, prev: number): DashboardDelta | null {
  const diff = curr - prev
  if (diff === 0 && curr === 0) return null
  const sign = diff > 0 ? '+' : diff < 0 ? '−' : ''
  return { value: `${sign}$${Math.abs(diff).toLocaleString('en-US')}`, down: diff < 0 }
}

export function calculateDashboardStats(bookings: Booking[], now = new Date()): DashboardStats {
  const active = bookings.filter(b => b.status !== 'cancelled')
  const cancelled = bookings.filter(b => b.status === 'cancelled')
  const confirmed = bookings.filter(b => b.status === 'confirmed')

  const todayISO = toISODate(now)
  const yesterdayISO = toISODate(addDays(now, -1))

  const weekStart = startOfWeek(now)
  const weekEnd = endOfWeek(now)
  const lastWeekStart = addDays(weekStart, -7)
  const lastWeekEnd = addDays(weekEnd, -7)

  const monthStart = startOfMonth(now)
  const monthEnd = endOfMonth(now)
  const lastMonthEnd = new Date(monthStart.getFullYear(), monthStart.getMonth(), 0, 23, 59, 59, 999)
  const lastMonthStart = startOfMonth(lastMonthEnd)

  const todayCount = active.filter(b => b.dateISO === todayISO).length
  const yesterdayCount = active.filter(b => b.dateISO === yesterdayISO).length

  const weekCount = active.filter(b => isWithinRange(b.dateISO, weekStart, weekEnd)).length
  const lastWeekCount = active.filter(b => isWithinRange(b.dateISO, lastWeekStart, lastWeekEnd)).length

  const monthRevenue = confirmed
    .filter(b => isWithinRange(b.dateISO, monthStart, monthEnd))
    .reduce((sum, b) => sum + (Number(b.total) || 0), 0)
  const lastMonthRevenue = confirmed
    .filter(b => isWithinRange(b.dateISO, lastMonthStart, lastMonthEnd))
    .reduce((sum, b) => sum + (Number(b.total) || 0), 0)

  const monthCancellations = cancelled
    .filter(b => isWithinRange(b.dateISO, monthStart, monthEnd))
    .length
  const lastMonthCancellations = cancelled
    .filter(b => isWithinRange(b.dateISO, lastMonthStart, lastMonthEnd))
    .length

  return {
    todayCount,
    todayDelta: formatDiff(todayCount, yesterdayCount),
    weekCount,
    weekDelta: formatDiff(weekCount, lastWeekCount),
    monthRevenue,
    monthRevenueDelta: formatMoneyDiff(monthRevenue, lastMonthRevenue),
    monthCancellations,
    monthCancellationsDelta: formatDiff(monthCancellations, lastMonthCancellations),
  }
}

export function groupWeekEvents(bookings: Booking[], weekAnchor: Date, days: Date[]): Record<number, Booking[]> {
  const result: Record<number, Booking[]> = {}
  const weekStart = startOfWeek(weekAnchor)
  const weekEnd = endOfWeek(weekAnchor)

  for (const b of bookings) {
    if (b.status === 'cancelled') continue
    if (!isWithinRange(b.dateISO, weekStart, weekEnd)) continue

    const idx = days.findIndex(d => toISODate(d) === b.dateISO)
    if (idx < 0) continue
    if (!result[idx]) result[idx] = []
    result[idx].push(b)
  }

  return result
}

export function getHourBounds(weekEventsByDay: Record<number, Booking[]>): HourBounds {
  let startHour = DEFAULT_HOUR_START
  let endHour = DEFAULT_HOUR_END

  for (const dayBookings of Object.values(weekEventsByDay)) {
    for (const b of dayBookings) {
      const startMin = timeToMinutes(b.time || '00:00')
      const endMin = b.endTime
        ? timeToMinutes(b.endTime)
        : startMin + (Number(b.durationMin) || 60)
      startHour = Math.min(startHour, Math.floor(startMin / 60))
      endHour = Math.max(endHour, Math.ceil(endMin / 60))
    }
  }

  return {
    startHour: Math.max(0, startHour),
    endHour: Math.min(24, endHour),
  }
}

export function getHours(bounds: HourBounds): string[] {
  return Array.from(
    { length: bounds.endHour - bounds.startHour },
    (_, i) => `${String(bounds.startHour + i).padStart(2, '0')}:00`,
  )
}

export function getEventGeometry(b: Booking, hourBounds: HourBounds): { top: number; height: number } {
  const startMin = timeToMinutes(b.time || '00:00')
  const endMin = b.endTime
    ? timeToMinutes(b.endTime)
    : startMin + (Number(b.durationMin) || 60)
  const hourStartMin = hourBounds.startHour * 60
  const top = ((startMin - hourStartMin) / 60) * HOUR_HEIGHT
  const height = Math.max(24, ((endMin - startMin) / 60) * HOUR_HEIGHT)
  return { top, height }
}

export function getUpcomingBookings(bookings: Booking[], now = new Date()): Booking[] {
  const todayISO = toISODate(now)
  return bookings
    .filter(b => b.dateISO >= todayISO && b.status !== 'cancelled')
    .sort((a, b) => {
      const byDate = (a.dateISO || '').localeCompare(b.dateISO || '')
      if (byDate !== 0) return byDate
      return (a.time || '').localeCompare(b.time || '')
    })
    .slice(0, 5)
}
QUALITY_REFACTOR_FILE

write_file 'src/pages/profile/AppearanceCard.tsx' <<'QUALITY_REFACTOR_FILE'
import { Card, Field } from '../../components/UI'
import type { Lang, Theme } from '../../types'

interface AppearanceCardProps {
  lang: Lang
  theme: Theme
  onThemeChange: (theme: Theme) => void
}

export default function AppearanceCard({ lang, theme, onThemeChange }: AppearanceCardProps) {
  return (
    <Card className="mb-6">
      <h3 className="mb-4">{lang === 'ru' ? 'Внешний вид' : 'Appearance'}</h3>
      <Field label={lang === 'ru' ? 'Тема' : 'Theme'}>
        <select
          className="select"
          value={theme}
          onChange={(e) => onThemeChange(e.target.value as Theme)}
        >
          <option value="dark">{lang === 'ru' ? 'Тёмная' : 'Dark'}</option>
          <option value="light">{lang === 'ru' ? 'Светлая' : 'Light'}</option>
        </select>
      </Field>
    </Card>
  )
}
QUALITY_REFACTOR_FILE

write_file 'src/pages/profile/ProfileFieldsCard.tsx' <<'QUALITY_REFACTOR_FILE'
import type { ChangeEvent } from 'react'
import { Avatar, Card, Field } from '../../components/UI'
import { useT } from '../../i18n/SettingsContext'
import type { Lang } from '../../types'
import type { ProfileFormValues } from './profileTypes'
import { getInitials } from './profileUtils'

interface ProfileFieldsCardProps {
  form: ProfileFormValues
  lang: Lang
  onFieldChange: (key: keyof ProfileFormValues) => (e: ChangeEvent<HTMLInputElement | HTMLTextAreaElement | HTMLSelectElement>) => void
  onLangChange: (lang: Lang) => void
}

export default function ProfileFieldsCard({ form, lang, onFieldChange, onLangChange }: ProfileFieldsCardProps) {
  const t = useT()

  return (
    <Card className="mb-6">
      <h3 className="mb-4">{t('profile.section.profile')}</h3>
      <div className="flex flex-gap-4 mb-6" style={{ alignItems: 'center' }}>
        <Avatar initials={getInitials(form.displayName || form.fullName || '?')} size={64} />
        <div>
          <div style={{ fontWeight: 600 }}>{form.displayName || form.fullName || '—'}</div>
          <div className="text-muted mt-2" style={{ fontSize: 13 }}>{form.email || ''}</div>
        </div>
      </div>

      <div className="grid grid-2">
        <Field label={t('profile.field.fullName')}><input className="input" value={form.fullName} onChange={onFieldChange('fullName')} /></Field>
        <Field label={t('profile.field.displayName')}><input className="input" value={form.displayName} onChange={onFieldChange('displayName')} /></Field>
        <Field label={t('profile.field.email')}><input className="input" value={form.email} onChange={onFieldChange('email')} /></Field>
        <Field label={t('profile.field.phone')}><input className="input" value={form.phone} onChange={onFieldChange('phone')} /></Field>
        <Field label={t('profile.field.timezone')}>
          <select className="select" value={form.timezone} onChange={onFieldChange('timezone')}>
            <option>Europe/Moscow (GMT+3)</option>
            <option>America/New_York (GMT-4)</option>
            <option>Europe/London (GMT+1)</option>
          </select>
        </Field>
        <Field label={t('profile.field.language')}>
          <select
            className="select"
            value={lang}
            onChange={(e) => onLangChange(e.target.value as Lang)}
          >
            <option value="en">English</option>
            <option value="ru">Русский</option>
          </select>
        </Field>
      </div>

      <Field label={t('profile.field.bio')}>
        <textarea className="textarea" value={form.bio} onChange={onFieldChange('bio')} />
      </Field>
    </Card>
  )
}
QUALITY_REFACTOR_FILE

write_file 'src/pages/profile/WorkingHoursCard.tsx' <<'QUALITY_REFACTOR_FILE'
import { Card } from '../../components/UI'
import { useT } from '../../i18n/SettingsContext'
import type { WorkingHours } from '../../types'
import WorkingHoursEditor from './WorkingHoursEditor'

interface WorkingHoursCardProps {
  value: WorkingHours
  onChange: (next: WorkingHours) => void
}

export default function WorkingHoursCard({ value, onChange }: WorkingHoursCardProps) {
  const t = useT()

  return (
    <Card className="mb-6">
      <h3 className="mb-4">{t('profile.workingHours')}</h3>
      <p className="text-muted mb-4" style={{ fontSize: 13 }}>{t('profile.workingHoursHint')}</p>
      <WorkingHoursEditor value={value} onChange={onChange} />
    </Card>
  )
}
QUALITY_REFACTOR_FILE

write_file 'src/pages/profile/WorkingHoursEditor.tsx' <<'QUALITY_REFACTOR_FILE'
import { useT } from '../../i18n/SettingsContext'
import { DAY_KEYS, type DayKey, type DayHours, type WorkingHours } from '../../types'

interface WorkingHoursEditorProps {
  value: WorkingHours
  onChange: (next: WorkingHours) => void
}

export default function WorkingHoursEditor({ value, onChange }: WorkingHoursEditorProps) {
  const t = useT()

  // Last non-null window per day — restored when the user re-enables a day they toggled off.
  // Falls back to 09:00-18:00 for never-set days.
  const fallback: DayHours = { start: '09:00', end: '18:00' }

  const updateDay = (key: DayKey, next: DayHours | null) => {
    onChange({ ...value, [key]: next })
  }

  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: 8 }}>
      {DAY_KEYS.map((key) => {
        const day = value[key]
        const enabled = day != null
        const eff = day ?? fallback
        return (
          <div key={key} style={{
            display: 'grid',
            gridTemplateColumns: '110px auto 1fr 1fr',
            alignItems: 'center',
            gap: 12,
          }}>
            <label className="flex flex-gap-2" style={{ alignItems: 'center', cursor: 'pointer' }}>
              <input
                type="checkbox"
                checked={enabled}
                onChange={(e) => updateDay(key, e.target.checked ? eff : null)}
              />
              <span style={{ fontWeight: 500 }}>{t(`day.${key}` as Parameters<typeof t>[0])}</span>
            </label>
            <span className="text-muted" style={{ fontSize: 12 }}>
              {enabled ? '' : t('profile.dayOff')}
            </span>
            <input
              className="input mono"
              type="time"
              value={eff.start}
              disabled={!enabled}
              onChange={(e) => updateDay(key, { ...eff, start: e.target.value })}
            />
            <input
              className="input mono"
              type="time"
              value={eff.end}
              disabled={!enabled}
              onChange={(e) => updateDay(key, { ...eff, end: e.target.value })}
            />
          </div>
        )
      })}
    </div>
  )
}
QUALITY_REFACTOR_FILE

write_file 'src/pages/profile/profileTypes.ts' <<'QUALITY_REFACTOR_FILE'
import type { WorkingHours } from '../../types'

export interface ProfileFormValues {
  fullName: string
  displayName: string
  email: string
  phone: string
  timezone: string
  bio: string
  workingHours: WorkingHours
}
QUALITY_REFACTOR_FILE

write_file 'src/pages/profile/profileUtils.ts' <<'QUALITY_REFACTOR_FILE'
import { DAY_KEYS, type WorkingHours } from '../../types'
import type { User } from '../../types'
import type { ProfileFormValues } from './profileTypes'

export const DEFAULT_WORKING_HOURS: WorkingHours = {
  mon: { start: '09:00', end: '18:00' },
  tue: { start: '09:00', end: '18:00' },
  wed: { start: '09:00', end: '18:00' },
  thu: { start: '09:00', end: '18:00' },
  fri: { start: '09:00', end: '18:00' },
}

/**
 * Backwards-compat: old User.workingHours was {start, end} (one window for all days).
 * Spread into Mon-Fri so existing users don't lose data on first edit.
 */
export function normalizeWorkingHours(wh: WorkingHours | { start?: string; end?: string } | undefined): WorkingHours {
  if (!wh) return DEFAULT_WORKING_HOURS

  const legacy = wh as { start?: string; end?: string }
  if (typeof legacy.start === 'string' && typeof legacy.end === 'string') {
    const w = { start: legacy.start, end: legacy.end }
    return { mon: w, tue: w, wed: w, thu: w, fri: w }
  }

  const newShape = wh as WorkingHours
  // Recovery: if every day is null or missing (e.g. user accidentally disabled
  // all days, or a buggy save wiped the object), restore defaults so they don't
  // end up with no availability at all.
  const hasAnyDay = DAY_KEYS.some(k => newShape[k])
  if (!hasAnyDay) return DEFAULT_WORKING_HOURS

  // Fill in missing (undefined) days from DEFAULT_WORKING_HOURS so partially-saved
  // profiles show all days the server actually treats as working. Explicit `null`
  // stays — that's the user's intent ("day off").
  const filled: WorkingHours = { ...newShape }
  for (const k of DAY_KEYS) {
    if (!(k in filled)) filled[k] = DEFAULT_WORKING_HOURS[k] ?? null
  }
  return filled
}

export function getInitials(name: string): string {
  return name.trim().split(/\s+/).slice(0, 2).map(w => w[0]?.toUpperCase() || '').join('') || '?'
}

export function getInitialProfileForm(user: User | null): ProfileFormValues {
  return {
    fullName: user?.name || '',
    displayName: user?.displayName || user?.name?.split(' ')[0] || '',
    email: user?.email || '',
    phone: user?.phone || '',
    timezone: user?.timezone || 'Europe/Moscow (GMT+3)',
    bio: user?.bio || '',
    workingHours: normalizeWorkingHours(user?.workingHours),
  }
}
QUALITY_REFACTOR_FILE

write_file 'src/pages/services/ServicesGrid.tsx' <<'QUALITY_REFACTOR_FILE'
import type { MouseEvent } from 'react'
import { Card, Pill } from '../../components/UI'
import EmptyState from '../../components/EmptyState'
import { loc } from '../../data/mock'
import { useT, useSettings } from '../../i18n/SettingsContext'
import type { Service } from '../../types'
import type { ServiceFilterItem } from './servicesTypes'

interface ServicesGridProps {
  services: Service[]
  filters: ServiceFilterItem[]
  activeFilter: string
  isEmptySearch: boolean
  busyId: string | null
  onFilterChange: (value: string) => void
  onEdit: (service: Service) => void
  onDelete: (service: Service) => void
}

export default function ServicesGrid({
  services,
  filters,
  activeFilter,
  isEmptySearch,
  busyId,
  onFilterChange,
  onEdit,
  onDelete,
}: ServicesGridProps) {
  const t = useT()
  const { lang } = useSettings()

  return (
    <div className="services-layout">
      <aside className="services-filters">
        <div className="filter-label">{t('services.filters')}</div>
        {filters.map(f => (
          <button
            key={f.value}
            className={`filter-item ${activeFilter === f.value ? 'active' : ''}`}
            onClick={() => onFilterChange(f.value)}
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
            {services.map((service) => (
              <ServiceCard
                key={service.id}
                service={service}
                busy={busyId === service.id}
                onEdit={onEdit}
                onDelete={onDelete}
              />
            ))}
          </div>
        )}
      </div>
    </div>
  )
}

function ServiceCard({
  service,
  busy,
  onEdit,
  onDelete,
}: {
  service: Service
  busy: boolean
  onEdit: (service: Service) => void
  onDelete: (service: Service) => void
}) {
  const t = useT()
  const { lang } = useSettings()

  const stopAndRun = (e: MouseEvent<HTMLButtonElement>, action: () => void) => {
    e.preventDefault()
    e.stopPropagation()
    action()
  }

  return (
    <Card
      as="link"
      to={`/services/${service.id}`}
      interactive
      style={{
        position: 'relative',
        ...(service.tone === 'accent' ? { borderColor: 'var(--accent-ring)' } : null),
      }}
    >
      <div className="service-actions">
        <button
          type="button"
          onClick={(e) => stopAndRun(e, () => onEdit(service))}
          className="btn-text"
          style={{ fontSize: 12, padding: '2px 6px' }}
        >
          {t('services.action.edit')}
        </button>
        <button
          type="button"
          onClick={(e) => stopAndRun(e, () => onDelete(service))}
          disabled={busy}
          className="btn-text"
          style={{ fontSize: 12, padding: '2px 6px', color: 'var(--danger)' }}
        >
          {busy ? t('bookings.deleting') : t('services.action.delete')}
        </button>
      </div>

      <div className="flex-between mb-4">
        <Pill tone={service.tone}>{loc(service.tag, lang)}</Pill>
        <span className="mono text-muted" style={{ fontSize: 12 }}>{service.duration} {t('services.minutes')}</span>
      </div>
      <h3 className="mb-2" style={{ paddingRight: 80 }}>{loc(service.name, lang)}</h3>
      <p className="text-muted line-clamp-3" style={{ fontSize: 13 }}>{loc(service.description, lang)}</p>
      <div className="text-accent mono mt-auto" style={{ fontSize: 16, fontWeight: 600, paddingTop: 'var(--s-6)' }}>${service.price}</div>
    </Card>
  )
}
QUALITY_REFACTOR_FILE

write_file 'src/pages/services/ServicesHeader.tsx' <<'QUALITY_REFACTOR_FILE'
import { Button } from '../../components/UI'
import { useT } from '../../i18n/SettingsContext'

interface ServicesHeaderProps {
  onCreate: () => void
}

export default function ServicesHeader({ onCreate }: ServicesHeaderProps) {
  const t = useT()

  return (
    <div className="flex-between mb-6">
      <div>
        <h1>{t('services.title')}</h1>
        <p className="subtitle mt-2">{t('services.subtitle')}</p>
      </div>
      <Button variant="ghost" onClick={onCreate}>{t('services.add')}</Button>
    </div>
  )
}
QUALITY_REFACTOR_FILE

write_file 'src/pages/services/ServicesSearch.tsx' <<'QUALITY_REFACTOR_FILE'
import { IconSearch } from '../../components/Icons'
import { useT } from '../../i18n/SettingsContext'

interface ServicesSearchProps {
  query: string
  onQueryChange: (query: string) => void
}

export default function ServicesSearch({ query, onQueryChange }: ServicesSearchProps) {
  const t = useT()

  return (
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
        value={query}
        onChange={(e) => onQueryChange(e.target.value)}
        placeholder={t('services.search.placeholder')}
        style={{
          flex: 1, border: 'none', outline: 'none', background: 'none',
          color: 'var(--text)', fontSize: 13,
        }}
      />
    </div>
  )
}
QUALITY_REFACTOR_FILE

write_file 'src/pages/services/ServicesState.tsx' <<'QUALITY_REFACTOR_FILE'
import { Button } from '../../components/UI'
import EmptyState from '../../components/EmptyState'
import { SkeletonCardGrid } from '../../components/Skeleton'
import { useT } from '../../i18n/SettingsContext'

export function ServicesError({ error }: { error: string }) {
  return (
    <div className="card" style={{ borderColor: 'rgba(248,113,113,0.32)', color: 'var(--danger)' }}>
      {error}
    </div>
  )
}

export function ServicesSkeleton() {
  return <SkeletonCardGrid />
}

export function EmptyServicesState({ onCreate }: { onCreate: () => void }) {
  const t = useT()

  return (
    <EmptyState
      illustration="services"
      title={t('services.empty')}
      action={<Button onClick={onCreate}>{t('services.add')}</Button>}
    />
  )
}
QUALITY_REFACTOR_FILE

write_file 'src/pages/services/servicesTypes.ts' <<'QUALITY_REFACTOR_FILE'
import type { Service } from '../../types'

// editing state: null = closed, {__new:true} = create, Service = edit
export type EditingState = Service | { __new: true } | null

export interface ServiceFilterItem {
  value: string
  label: string
  count: number
}

export const isEditingService = (editing: EditingState): editing is Service =>
  editing !== null && !('__new' in editing)
QUALITY_REFACTOR_FILE

write_file 'src/pages/services/servicesUtils.ts' <<'QUALITY_REFACTOR_FILE'
import { loc } from '../../data/mock'
import type { Lang, Service } from '../../types'
import type { ServiceFilterItem } from './servicesTypes'

export function matchesServiceQuery(service: Service, query: string, lang: Lang): boolean {
  if (!query) return true
  const haystack = [
    loc(service.name, lang),
    loc(service.description, lang),
    loc(service.tag, lang),
    service.name?.en, service.name?.ru,
    service.description?.en, service.description?.ru,
    service.tag?.en, service.tag?.ru,
  ].filter(Boolean).join(' ').toLowerCase()
  return haystack.includes(query.toLowerCase())
}

export function buildServiceFilters(
  services: Service[],
  query: string,
  lang: Lang,
  allLabel: string,
): ServiceFilterItem[] {
  const matchedAll = services.filter(s => matchesServiceQuery(s, query, lang))
  const seen = new Map<string, Service['tag']>()

  for (const s of services) {
    const key = s.tag?.en
    if (key && !seen.has(key)) seen.set(key, s.tag)
  }

  return [
    { value: 'all', label: allLabel, count: matchedAll.length },
    ...[...seen.entries()].map(([key, tag]) => ({
      value: key,
      label: loc(tag, lang),
      count: matchedAll.filter(s => s.tag?.en === key).length,
    })),
  ]
}

export function filterServices(
  services: Service[],
  activeTag: string,
  query: string,
  lang: Lang,
): Service[] {
  let list = services
  if (activeTag !== 'all') list = list.filter(s => s.tag?.en === activeTag)
  if (query) list = list.filter(s => matchesServiceQuery(s, query, lang))
  return list
}
QUALITY_REFACTOR_FILE

write_file 'tests/booking-detail-utils.test.mjs' <<'QUALITY_REFACTOR_FILE'
import { describe, expect, it } from 'vitest'
import {
  formatBookingDate,
  getBookingRef,
  getBookingTimeRange,
  getStatusTone,
} from '../src/pages/booking-detail/bookingDetailUtils.ts'

const booking = {
  id: 7,
  providerId: 1,
  customerId: 1,
  dateISO: '2099-06-16',
  time: '10:00',
  endTime: '11:00',
  durationMin: 60,
  service: 'English lesson',
  total: 100,
  status: 'confirmed',
  withName: 'Anna Smith',
  initials: 'AS',
  customerEmail: 'anna@example.com',
  customerPhone: null,
  notes: null,
  createdAt: '2099-01-01',
}

describe('bookingDetailUtils', () => {
  it('formats booking reference with zero padding', () => {
    expect(getBookingRef(7)).toBe('SLT-0007')
    expect(getBookingRef('42')).toBe('SLT-0042')
  })

  it('formats time range with optional end time', () => {
    expect(getBookingTimeRange(booking)).toBe('10:00 – 11:00')
    expect(getBookingTimeRange({ ...booking, endTime: undefined })).toBe('10:00')
  })

  it('maps booking status to pill tone', () => {
    expect(getStatusTone('confirmed')).toBe('success')
    expect(getStatusTone('cancelled')).toBe('danger')
    expect(getStatusTone('pending')).toBe('accent')
  })

  it('formats date and handles missing value', () => {
    expect(formatBookingDate(undefined, 'en')).toBe('')
    expect(formatBookingDate('2099-06-16', 'en')).toContain('2099')
  })
})
QUALITY_REFACTOR_FILE

write_file 'tests/bookings-utils.test.mjs' <<'QUALITY_REFACTOR_FILE'
import { describe, expect, it } from 'vitest'
import {
  addMinutesHHMM,
  annotateBookings,
  filterBookings,
  formatDateShort,
  groupBookingsByStatus,
  sortBookings,
} from '../src/pages/bookings/bookingsUtils.ts'

const baseBooking = {
  id: '1',
  providerId: 1,
  customerId: 1,
  dateISO: '2099-06-16',
  time: '10:00',
  endTime: '11:00',
  durationMin: 60,
  service: 'English lesson',
  total: 100,
  status: 'confirmed',
  withName: 'Anna Smith',
  initials: 'AS',
  customerEmail: 'anna@example.com',
  customerPhone: null,
  notes: null,
  createdAt: '2099-01-01',
}

describe('bookingsUtils', () => {
  it('sorts bookings by date and time', () => {
    const sorted = sortBookings([
      { ...baseBooking, id: '3', dateISO: '2099-06-17', time: '09:00' },
      { ...baseBooking, id: '1', dateISO: '2099-06-16', time: '11:00' },
      { ...baseBooking, id: '2', dateISO: '2099-06-16', time: '10:00' },
    ])

    expect(sorted.map(b => b.id)).toEqual(['2', '1', '3'])
  })

  it('groups bookings into upcoming, past and cancelled', () => {
    const annotated = annotateBookings([
      { ...baseBooking, id: '1', dateISO: '2099-06-16', status: 'confirmed' },
      { ...baseBooking, id: '2', dateISO: '2099-06-15', status: 'confirmed' },
      { ...baseBooking, id: '3', dateISO: '2099-06-17', status: 'cancelled' },
    ])

    const groups = groupBookingsByStatus(annotated, '2099-06-16')

    expect(groups.upcoming.map(x => x.b.id)).toEqual(['1'])
    expect(groups.past.map(x => x.b.id)).toEqual(['2'])
    expect(groups.cancelled.map(x => x.b.id)).toEqual(['3'])
  })

  it('filters visible bookings by customer, service, email or date', () => {
    const annotated = annotateBookings([
      { ...baseBooking, id: '1', service: 'English lesson', withName: 'Anna Smith' },
      { ...baseBooking, id: '2', service: 'Math lesson', withName: 'Bob Brown', customerEmail: 'bob@example.com' },
    ])
    const groups = { upcoming: annotated, past: [], cancelled: [] }

    expect(filterBookings(groups, 'upcoming', 'math').map(x => x.b.id)).toEqual(['2'])
    expect(filterBookings(groups, 'upcoming', 'anna').map(x => x.b.id)).toEqual(['1'])
    expect(filterBookings(groups, 'upcoming', 'bob@example.com').map(x => x.b.id)).toEqual(['2'])
  })

  it('adds minutes to HH:MM time', () => {
    expect(addMinutesHHMM('10:30', 90)).toBe('12:00')
    expect(addMinutesHHMM('23:30', 60)).toBe('00:30')
  })

  it('formats short dates and handles missing value', () => {
    expect(formatDateShort(undefined, 'en')).toBe('—')
    expect(formatDateShort('2099-06-16', 'en')).toMatch(/Jun|16/)
  })
})
QUALITY_REFACTOR_FILE

write_file 'tests/command-palette-utils.test.mjs' <<'QUALITY_REFACTOR_FILE'
import { describe, expect, it } from 'vitest'
import { buildPaletteResults, splitResultGroups } from '../src/components/command-palette/commandPaletteUtils.ts'

const t = (key) => key === 'services.minutes' ? 'min' : key

const service = {
  id: 'svc-1',
  providerId: 1,
  tag: { en: 'lesson', ru: 'урок' },
  tone: 'accent',
  duration: 60,
  price: 100,
  name: { en: 'English lesson', ru: 'Урок английского' },
  description: { en: 'Speaking practice', ru: 'Разговорная практика' },
}

const booking = {
  id: 7,
  providerId: 1,
  customerId: 1,
  serviceId: 'svc-1',
  dateISO: '2099-06-16',
  time: '10:00',
  endTime: '11:00',
  durationMin: 60,
  service: 'English lesson',
  total: 100,
  status: 'confirmed',
  withName: 'Anna Smith',
  initials: 'AS',
  customerEmail: 'anna@example.com',
  customerPhone: '+100000000',
  notes: 'Bring workbook',
  createdAt: '2099-01-01',
}

describe('commandPaletteUtils', () => {
  it('returns no results for an empty query', () => {
    const results = buildPaletteResults({
      query: '   ',
      services: [service],
      bookings: [booking],
      lang: 'en',
      t,
    })

    expect(results).toEqual([])
  })

  it('finds services by localized service text', () => {
    const results = buildPaletteResults({
      query: 'speaking',
      services: [service],
      bookings: [],
      lang: 'en',
      t,
    })

    expect(results).toMatchObject([
      {
        id: 'service-svc-1',
        group: 'services',
        title: 'English lesson',
        to: '/services/svc-1',
      },
    ])
  })

  it('finds bookings by customer email and maps to booking detail page', () => {
    const results = buildPaletteResults({
      query: 'anna@example.com',
      services: [],
      bookings: [booking],
      lang: 'en',
      t,
    })

    expect(results).toMatchObject([
      {
        id: 'booking-7',
        group: 'bookings',
        title: 'English lesson — Anna Smith',
        to: '/bookings/7',
      },
    ])
  })

  it('splits mixed results by group', () => {
    const results = buildPaletteResults({
      query: 'english',
      services: [service],
      bookings: [booking],
      lang: 'en',
      t,
    })
    const grouped = splitResultGroups(results)

    expect(grouped.serviceItems).toHaveLength(1)
    expect(grouped.bookingItems).toHaveLength(1)
  })
})
QUALITY_REFACTOR_FILE

write_file 'tests/dashboard-utils.test.mjs' <<'QUALITY_REFACTOR_FILE'
import { describe, expect, it } from 'vitest'
import {
  calculateDashboardStats,
  getEventGeometry,
  getHourBounds,
  getHours,
  getUpcomingBookings,
  groupWeekEvents,
} from '../src/pages/dashboard/dashboardUtils.ts'
import { addDays, startOfWeek } from '../src/utils/date.ts'

const baseBooking = {
  id: 1,
  providerId: 1,
  customerId: 1,
  dateISO: '2099-06-16',
  time: '10:00',
  endTime: '11:00',
  durationMin: 60,
  service: 'Lesson',
  total: 100,
  status: 'confirmed',
  withName: 'Client',
  initials: 'C',
  customerEmail: 'client@example.com',
  customerPhone: null,
  notes: null,
  createdAt: '2099-01-01',
}

describe('dashboardUtils', () => {
  it('calculates dashboard stats for day, week, revenue and cancellations', () => {
    const now = new Date(2099, 5, 16, 12, 0)
    const bookings = [
      { ...baseBooking, id: 1, dateISO: '2099-06-16', status: 'confirmed', total: 100 },
      { ...baseBooking, id: 2, dateISO: '2099-06-17', status: 'confirmed', total: 200 },
      { ...baseBooking, id: 3, dateISO: '2099-06-18', status: 'cancelled', total: 300 },
      { ...baseBooking, id: 4, dateISO: '2099-06-09', status: 'confirmed', total: 50 },
    ]

    const stats = calculateDashboardStats(bookings, now)

    expect(stats.todayCount).toBe(1)
    expect(stats.weekCount).toBe(2)
    expect(stats.monthRevenue).toBe(350)
    expect(stats.monthCancellations).toBe(1)
  })

  it('groups active week events by day index and skips cancelled bookings', () => {
    const weekAnchor = new Date(2099, 5, 16)
    const weekStart = startOfWeek(weekAnchor)
    const days = Array.from({ length: 7 }, (_, i) => addDays(weekStart, i))
    const bookings = [
      { ...baseBooking, id: 1, dateISO: '2099-06-16', status: 'confirmed' },
      { ...baseBooking, id: 2, dateISO: '2099-06-16', status: 'cancelled' },
      { ...baseBooking, id: 3, dateISO: '2099-06-17', status: 'confirmed' },
    ]

    const grouped = groupWeekEvents(bookings, weekAnchor, days)

    expect(grouped[1].map(b => b.id)).toEqual([1])
    expect(grouped[2].map(b => b.id)).toEqual([3])
  })

  it('expands visible hours to include early and late bookings', () => {
    const bounds = getHourBounds({
      0: [
        { ...baseBooking, id: 1, time: '07:30', endTime: '08:30' },
        { ...baseBooking, id: 2, time: '20:00', endTime: '21:00' },
      ],
    })

    expect(bounds).toEqual({ startHour: 7, endHour: 21 })
    expect(getHours(bounds)).toContain('20:00')
  })

  it('returns event geometry in pixels relative to visible hour bounds', () => {
    const geometry = getEventGeometry(
      { ...baseBooking, time: '10:30', endTime: '12:00' },
      { startHour: 9, endHour: 18 },
    )

    expect(geometry.top).toBe(84)
    expect(geometry.height).toBe(84)
  })

  it('returns only upcoming non-cancelled bookings sorted by date and time', () => {
    const now = new Date(2099, 5, 16, 12, 0)
    const bookings = [
      { ...baseBooking, id: 1, dateISO: '2099-06-17', time: '12:00', status: 'confirmed' },
      { ...baseBooking, id: 2, dateISO: '2099-06-16', time: '09:00', status: 'confirmed' },
      { ...baseBooking, id: 3, dateISO: '2099-06-18', time: '10:00', status: 'cancelled' },
      { ...baseBooking, id: 4, dateISO: '2099-06-15', time: '10:00', status: 'confirmed' },
    ]

    expect(getUpcomingBookings(bookings, now).map(b => b.id)).toEqual([2, 1])
  })
})
QUALITY_REFACTOR_FILE

write_file 'tests/profile-utils.test.mjs' <<'QUALITY_REFACTOR_FILE'
import { describe, expect, it } from 'vitest'
import {
  DEFAULT_WORKING_HOURS,
  getInitialProfileForm,
  getInitials,
  normalizeWorkingHours,
} from '../src/pages/profile/profileUtils.ts'

describe('profileUtils', () => {
  it('returns default working hours for missing value', () => {
    expect(normalizeWorkingHours(undefined)).toEqual(DEFAULT_WORKING_HOURS)
  })

  it('expands legacy flat working hours to weekdays', () => {
    const normalized = normalizeWorkingHours({ start: '10:00', end: '17:00' })

    expect(normalized.mon).toEqual({ start: '10:00', end: '17:00' })
    expect(normalized.fri).toEqual({ start: '10:00', end: '17:00' })
    expect(normalized.sat).toBeUndefined()
  })

  it('keeps explicit day off and fills missing days from defaults', () => {
    const normalized = normalizeWorkingHours({ mon: null, tue: { start: '11:00', end: '15:00' } })

    expect(normalized.mon).toBeNull()
    expect(normalized.tue).toEqual({ start: '11:00', end: '15:00' })
    expect(normalized.wed).toEqual(DEFAULT_WORKING_HOURS.wed)
  })

  it('recovers defaults when all days are disabled or missing', () => {
    expect(normalizeWorkingHours({ mon: null, tue: null })).toEqual(DEFAULT_WORKING_HOURS)
  })

  it('builds initials from one or two words', () => {
    expect(getInitials('Anna Smith')).toBe('AS')
    expect(getInitials('Anna')).toBe('A')
    expect(getInitials('')).toBe('?')
  })

  it('creates initial profile form from user data', () => {
    const form = getInitialProfileForm({
      id: 1,
      email: 'anna@example.com',
      name: 'Anna Smith',
      displayName: 'Anna',
      phone: '+1000',
      timezone: 'Europe/London (GMT+1)',
      bio: 'Tutor',
      workingHours: { start: '10:00', end: '16:00' },
    })

    expect(form).toMatchObject({
      fullName: 'Anna Smith',
      displayName: 'Anna',
      email: 'anna@example.com',
      phone: '+1000',
      timezone: 'Europe/London (GMT+1)',
      bio: 'Tutor',
    })
    expect(form.workingHours.mon).toEqual({ start: '10:00', end: '16:00' })
  })
})
QUALITY_REFACTOR_FILE

write_file 'tests/services-utils.test.mjs' <<'QUALITY_REFACTOR_FILE'
import { describe, expect, it } from 'vitest'
import { buildServiceFilters, filterServices, matchesServiceQuery } from '../src/pages/services/servicesUtils.ts'
import {
  toServiceFormValues,
  toServicePayload,
  validateServiceForm,
} from '../src/components/service-form/serviceFormUtils.ts'

const t = (key) => key

const service = {
  id: 'svc-1',
  providerId: 1,
  tag: { en: 'lesson', ru: 'урок' },
  tone: 'accent',
  duration: 60,
  price: 100,
  name: { en: 'English lesson', ru: 'Урок английского' },
  description: { en: 'Speaking practice', ru: 'Разговорная практика' },
}

const secondService = {
  ...service,
  id: 'svc-2',
  tag: { en: 'consulting', ru: 'консультация' },
  name: { en: 'Career consulting', ru: 'Карьерная консультация' },
  description: { en: 'Career plan', ru: 'План карьеры' },
}

describe('servicesUtils', () => {
  it('matches service by localized text', () => {
    expect(matchesServiceQuery(service, 'speaking', 'en')).toBe(true)
    expect(matchesServiceQuery(service, 'карьеры', 'ru')).toBe(false)
  })

  it('builds filters with counts respecting query', () => {
    const filters = buildServiceFilters([service, secondService], 'career', 'en', 'All')

    expect(filters).toEqual([
      { value: 'all', label: 'All', count: 1 },
      { value: 'lesson', label: 'lesson', count: 0 },
      { value: 'consulting', label: 'consulting', count: 1 },
    ])
  })

  it('filters services by tag and query', () => {
    expect(filterServices([service, secondService], 'consulting', '', 'en').map(s => s.id)).toEqual(['svc-2'])
    expect(filterServices([service, secondService], 'all', 'english', 'en').map(s => s.id)).toEqual(['svc-1'])
  })
})

describe('serviceFormUtils', () => {
  it('maps service to form values', () => {
    expect(toServiceFormValues(service)).toMatchObject({
      tagEn: 'lesson',
      tagRu: 'урок',
      tone: 'accent',
      duration: 60,
      price: 100,
      nameEn: 'English lesson',
      nameRu: 'Урок английского',
      descEn: 'Speaking practice',
      descRu: 'Разговорная практика',
    })
  })

  it('maps form values to trimmed payload', () => {
    const payload = toServicePayload({
      tagEn: ' lesson ',
      tagRu: ' урок ',
      tone: 'muted',
      duration: '45',
      price: '120',
      nameEn: ' Name ',
      nameRu: ' Имя ',
      descEn: ' Desc ',
      descRu: ' Описание ',
    })

    expect(payload).toEqual({
      tag: { en: 'lesson', ru: 'урок' },
      tone: 'muted',
      duration: 45,
      price: 120,
      name: { en: 'Name', ru: 'Имя' },
      description: { en: 'Desc', ru: 'Описание' },
    })
  })

  it('validates required fields and numeric constraints', () => {
    const errors = validateServiceForm({
      tagEn: '', tagRu: '', tone: 'muted', duration: 0, price: -1,
      nameEn: '', nameRu: '', descEn: '', descRu: '',
    }, t)

    expect(errors).toMatchObject({
      tagEn: 'validation.required',
      duration: 'validation.positiveNumber',
      price: 'validation.nonNegativeNumber',
    })
  })
})
QUALITY_REFACTOR_FILE

echo ""
echo "Installed refactor files."
echo "Backup directory: $BACKUP_DIR"
echo ""
echo "Recommended checks:"
echo "  npm test"
echo "  npm run build"
echo ""
echo "If you need to rollback changed files:"
echo "  cp -R $BACKUP_DIR/* ."
