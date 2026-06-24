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
