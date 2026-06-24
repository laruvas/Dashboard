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
