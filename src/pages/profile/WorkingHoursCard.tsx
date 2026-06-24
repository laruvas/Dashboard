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
