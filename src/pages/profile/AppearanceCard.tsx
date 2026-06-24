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
