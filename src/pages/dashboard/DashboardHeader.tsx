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
