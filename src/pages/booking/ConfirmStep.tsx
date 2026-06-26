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
          <div style={{ fontWeight: 600 }}>
            {selectedService ? loc(selectedService.name, lang) : '—'}
          </div>
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
          <div className="text-muted mt-2" style={{ fontSize: 13 }}>
            {customer.email}
          </div>
          {customer.phone && (
            <div className="text-muted mono" style={{ fontSize: 13 }}>
              {customer.phone}
            </div>
          )}
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
        <label
          className="flex flex-gap-3 mb-2"
          style={{ alignItems: 'flex-start', cursor: 'pointer', fontSize: 14 }}
        >
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

        {error && (
          <div className="card mb-4">
            <div>⚠ {error}</div>
          </div>
        )}

        <div className="flex flex-gap-3 mt-4">
          <Button variant="ghost" onClick={onBack} disabled={saving}>
            {t('common.back')}
          </Button>
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
