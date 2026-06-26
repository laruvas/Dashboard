import { useMemo, useState } from 'react'
import { useSettings } from '../i18n/SettingsContext'

// Day-of-week labels per language. Calendar is Monday-first.
const DOW_BY_LANG: Record<'en' | 'ru', string[]> = {
  en: ['M', 'T', 'W', 'T', 'F', 'S', 'S'],
  ru: ['П', 'В', 'С', 'Ч', 'П', 'С', 'В'],
}

interface DayCell {
  date: Date
  inMonth: boolean
}

function buildMonth(year: number, month: number): DayCell[] {
  const first = new Date(year, month, 1)
  const startWeekday = (first.getDay() + 6) % 7 // make Monday = 0
  const daysInMonth = new Date(year, month + 1, 0).getDate()
  const prevMonthDays = new Date(year, month, 0).getDate()

  const cells: DayCell[] = []
  for (let i = startWeekday - 1; i >= 0; i--) {
    cells.push({ date: new Date(year, month - 1, prevMonthDays - i), inMonth: false })
  }
  for (let d = 1; d <= daysInMonth; d++) {
    cells.push({ date: new Date(year, month, d), inMonth: true })
  }
  while (cells.length % 7 !== 0) {
    const last = cells[cells.length - 1].date
    cells.push({
      date: new Date(last.getFullYear(), last.getMonth(), last.getDate() + 1),
      inMonth: false,
    })
  }
  return cells
}

const sameDay = (a: Date | null | undefined, b: Date | null | undefined): boolean =>
  Boolean(a && b && a.toDateString() === b.toDateString())

// Compare dates at day-precision: -1 if a<b, 0 if same day, 1 if a>b
function dayCompare(a: Date, b: Date): number {
  const da = new Date(a.getFullYear(), a.getMonth(), a.getDate())
  const db = new Date(b.getFullYear(), b.getMonth(), b.getDate())
  return da < db ? -1 : da > db ? 1 : 0
}

interface CalendarProps {
  value?: Date
  onChange?: (d: Date) => void
  eventsOn?: Date[]
  compact?: boolean
  minDate?: Date
}

export default function Calendar({
  value,
  onChange,
  eventsOn = [],
  compact = false,
  minDate,
}: CalendarProps) {
  const { lang } = useSettings()
  const today = new Date()
  const initial = value || today
  const [cursor, setCursor] = useState(new Date(initial.getFullYear(), initial.getMonth(), 1))

  const cells = buildMonth(cursor.getFullYear(), cursor.getMonth())
  const eventDates = new Set(eventsOn.map((d) => d.toDateString()))

  // Localized "Month Year" header via Intl — handles all 12 months in any locale.
  const monthLabel = useMemo(() => {
    const locale = lang === 'ru' ? 'ru-RU' : 'en-US'
    const s = cursor.toLocaleDateString(locale, { month: 'long', year: 'numeric' })
    // Capitalize first letter (ru-RU returns lowercase "июнь 2026")
    return s.charAt(0).toUpperCase() + s.slice(1)
  }, [cursor, lang])

  const dow = DOW_BY_LANG[lang]

  const prev = () => setCursor(new Date(cursor.getFullYear(), cursor.getMonth() - 1, 1))
  const next = () => setCursor(new Date(cursor.getFullYear(), cursor.getMonth() + 1, 1))

  return (
    <div className="calendar" style={compact ? { padding: 12 } : undefined}>
      <div className="cal-head">
        <div className="month" style={compact ? { fontSize: 13 } : undefined}>
          {monthLabel}
        </div>
        <div className="cal-nav">
          <button onClick={prev}>‹</button>
          <button onClick={next}>›</button>
        </div>
      </div>
      <div className="cal-grid">
        {dow.map((d, i) => (
          <div className="dow" key={i}>
            {d}
          </div>
        ))}
        {cells.map((c, i) => {
          const isPast = Boolean(minDate && dayCompare(c.date, minDate) < 0)
          const classes = ['day']
          if (!c.inMonth) classes.push('muted')
          if (sameDay(c.date, today)) classes.push('today')
          if (sameDay(c.date, value)) classes.push('selected')
          if (eventDates.has(c.date.toDateString())) classes.push('has-event')
          if (isPast) classes.push('disabled')
          return (
            <div
              key={i}
              className={classes.join(' ')}
              aria-disabled={isPast || undefined}
              onClick={() => c.inMonth && !isPast && onChange?.(c.date)}
            >
              {c.date.getDate()}
            </div>
          )
        })}
      </div>
    </div>
  )
}
