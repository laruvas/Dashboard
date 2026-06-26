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
      <Button variant="ghost" onClick={onCreate}>
        {t('services.add')}
      </Button>
    </div>
  )
}
