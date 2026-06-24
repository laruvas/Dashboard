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
