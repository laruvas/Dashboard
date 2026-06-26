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
        <Button as="link" to="/booking" size="sm">
          + {t('nav.newBooking')}
        </Button>
      </div>
    </div>
  )
}
