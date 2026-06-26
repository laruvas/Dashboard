# HANDOFF — Slottr Appointment Scheduler

> Документ для AI-агента, который продолжит работу над проектом.
> Содержит контекст, архитектурные решения и backlog.

---

## 1. Общая информация

**Slottr** — веб-приложение для записи на приём (appointment scheduler).
Изначально был дизайн-макет, превратился в полнофункциональный SPA с CRUD,
двумя языками, темами и т.д.

**Стек:**

- React 18 + TypeScript (strict mode) + Vite 5
- React Router v6
- JSON Server (в роли фейкового бэкенда)
- Никаких UI-фреймворков — кастомные компоненты + CSS-переменные
- Никаких state-management библиотек — React Context + useState
- Никаких form-библиотек — нативная валидация на useState

**Принципы кода (важно соблюдать):**

- **Strict TypeScript** — `tsc --noEmit` всегда 0 ошибок
- **Минимум зависимостей** — каждая новая dep требует обоснования
- **Хирургические правки** — менять только то что просили
- **Discriminated unions** для полиморфных компонентов
- **Promise-based API** для конфирм-диалогов (см. `Confirm.tsx`)
- **300ms задержка** для skeleton-лоадеров чтобы не мерцать
- **i18n-ключи строго типизированы** через `TKey = keyof typeof translations.en`

---

## 2. Структура проекта

```
slottr-app/
├── db.json                          # JSON Server БД (bookings + services)
├── package.json
├── tsconfig.json                    # strict: true, allowJs: true
├── tsconfig.node.json
├── vite.config.js
├── index.html                       # → /src/main.tsx
└── src/
    ├── main.tsx                     # Bootstrap: 4 Provider'а + Router
    ├── App.tsx                      # Routes
    ├── vite-env.d.ts
    │
    ├── types/index.ts               # Все доменные типы (Lang, Theme, Service, Booking, …)
    │
    ├── i18n/
    │   ├── translations.ts          # 230+ ключей × 2 языка (en/ru). `satisfies` typing
    │   └── SettingsContext.tsx      # theme + lang + t() с типизированными ключами
    │
    ├── data/
    │   ├── bookingsApi.ts           # list/get/create/patch/delete
    │   ├── servicesApi.ts           # то же
    │   └── mock.ts                  # static notifications + loc() helper
    │
    ├── utils/
    │   ├── ics.ts                   # buildIcsBlob(booking), downloadIcs()
    │   └── date.ts                  # toISODate, startOfWeek, endOfMonth, isWithinRange, …
    │
    ├── components/
    │   ├── Icons.tsx                # 17 inline SVG-иконок
    │   ├── UI.tsx                   # Button, Card, Pill, Stat, Field, Avatar, Divider, LabelMono, Tabs
    │   │                            # Button и Card используют discriminated unions (as="button"|"link")
    │   ├── Calendar.tsx             # Месячный календарь с minDate, eventsOn
    │   ├── Modal.tsx                # A11y модалка (focus-trap, Esc, body scroll lock)
    │   ├── Toggles.tsx              # ThemeToggle, LangToggle
    │   ├── ServiceForm.tsx          # CRUD-форма услуги (нативная валидация)
    │   ├── Confirm.tsx              # Promise-based confirmDialog() + useConfirm()
    │   ├── Toast.tsx                # useToast() с success/error/info
    │   ├── CommandPalette.tsx       # ⌘K / Ctrl+K глобальный поиск
    │   ├── EmptyState.tsx           # 4 SVG-иллюстрации (calendar/services/search/bell)
    │   └── Skeleton.tsx             # Skeleton + хук useDelayedFlag(loading, 300)
    │
    ├── layouts/
    │   └── AppLayout.tsx            # Sidebar + topbar (search button → palette)
    │
    ├── pages/
    │   ├── Login.tsx                # ⚠️ ФЕЙК — любой email/password → /dashboard
    │   ├── Dashboard.tsx            # Stats + weekly calendar + upcoming (всё на реальных данных)
    │   ├── Profile.tsx              # ⚠️ Save показывает toast, но не сохраняет в БД
    │   ├── Services.tsx             # Каталог + CRUD + sidebar-фильтры + поиск
    │   ├── ServiceDetail.tsx        # Read-only детали + кнопка "Записаться" → /booking?service=:id
    │   ├── Booking.tsx              # 4-шаговый booking flow (самый сложный файл)
    │   ├── Bookings.tsx             # Таблица + 3 вкладки (Upcoming/Past/Cancelled)
    │   ├── BookingDetail.tsx        # Детали + Add to calendar + Cancel/Delete
    │   ├── Notifications.tsx        # ⚠️ Статичные данные из mock.ts
    │   └── Confirmation.tsx         # Экран "Вы записаны" + Add to calendar
    │
    └── styles/
        └── app.css                  # Дизайн-система через CSS-переменные. 2 темы.
```

---

## 3. Архитектурные решения

### 3.1 Локализация (i18n)

- Два языка: `en`, `ru` — определены как `type Lang`
- **Все** UI-строки в `translations.ts`, ключи типизированы
- Для пользовательского контента — `Localized<T> = Record<Lang, T>`:
  ```ts
  interface Service {
    name: Localized // { en: string, ru: string }
    description: Localized
    tag: Localized
  }
  ```
- Хелпер `loc(field, lang)` извлекает значение с fallback на `en`
- При добавлении ключа — обязательно в обоих языках. Иначе TS не упадёт (там `Record<string, string>`), но `TKey` потеряет в полноте.

### 3.2 Темы

- `data-theme="dark|light"` на `<html>`
- CSS-переменные на `:root` (общие) и на `[data-theme="..."]` (специфичные)
- Автоопределение по `prefers-color-scheme`
- Сохраняется в `localStorage`

### 3.3 Provider-иерархия (важна последовательность!)

```tsx
<SettingsProvider>           // theme + lang — нужен всем
  <ToastProvider>            // глобальный toast
    <ConfirmProvider>        // использует Modal внутри
      <BrowserRouter>
        <CommandPaletteProvider>  // использует useNavigate
          <App />
```

### 3.4 Discriminated unions у полиморфных компонентов

`Button` и `Card` могут быть либо `<button>` либо `<Link>`:

```tsx
<Button onClick={...}>Submit</Button>
<Button as="link" to="/dashboard">Go home</Button>
// Эти комбинации — TS-ошибка:
<Button as="link" />              // нет `to`
<Button to="/x">Click</Button>    // нет `as="link"`
```

### 3.5 Confirm + Toast (replaces native confirm/alert)

```tsx
const confirm = useConfirm()
const toast = useToast()

const ok = await confirm({ title, message, danger: true })
if (!ok) return
try {
  await deleteThing()
  toast.success('Deleted')
} catch (e) {
  toast.error(e instanceof Error ? e.message : 'Failed')
}
```

### 3.6 Skeletons с задержкой

```tsx
const loading = ... // обычный state
const showSkeleton = useDelayedFlag(loading, 300)
// показывает skeleton только если loading ≥ 300ms
```

### 3.7 Конфликт-чек слотов

В `Booking.tsx` step 2: слот disabled если
`[slot, slot+duration)` пересекается с любой существующей `[start, end)` бронью.
Также блокируются прошедшие слоты сегодняшнего дня (+15 мин буфер).

### 3.8 .ics экспорт

`utils/ics.ts` генерирует валидный iCalendar 2.0 (RFC 5545):
CRLF, экранирование, line folding, TZID, UID для идемпотентного импорта.

---

## 4. JSON Server (бэкенд)

**Запуск:** `npm run dev:all` поднимает Vite (:5173) + JSON Server (:3001) параллельно.

**Ресурсы в `db.json`:**

- `bookings: Booking[]` — id строковый (json-server@1 генерит UUID-like)
- `services: Service[]` — то же

**Endpoints (стандарт REST):**

- `GET    /bookings` — список
- `GET    /bookings/:id` — один
- `POST   /bookings` — создать (id генерируется)
- `PATCH  /bookings/:id` — частичное обновление
- `DELETE /bookings/:id`
- Аналогично для `/services`

**API-обёртки** в `data/bookingsApi.ts` и `data/servicesApi.ts` — типизированы.

---

## 5. Что готово ✅

- Дизайн-система + 2 темы (dark/light)
- i18n (RU/EN) с типизированными ключами
- API через JSON Server (CRUD bookings + services)
- Booking flow (4 шага: услуга → дата/время → данные клиента → подтверждение)
- Валидация форм (нативная, useState-based)
- CRUD услуг с модалкой
- Detail-страницы Booking/Service
- Dashboard с реальными статистиками (today/week/month с дельтами)
- Недельный календарь 09–18 с реальными бронями + prev/today/next
- Confirm + Toast (заменили все confirm/alert)
- ⌘K Command Palette (поиск по services + bookings)
- .ics экспорт ("Добавить в календарь")
- Защита от прошлых дат/времени
- Конфликт-чек слотов по duration
- Sidebar категорий + search в каталоге услуг
- Empty states с иллюстрациями
- Skeleton loaders с 300ms задержкой
- Strict TypeScript на 100%

---

## 6. Что НЕ готово ⚠️ (backlog)

### Критично для production

1. **Login — фейк.** Любой email/password пускает на `/dashboard`. Нет userContext, имя "Alex Kim" захардкожено в sidebar. Нужна реальная auth (json-server-auth или сторонний сервис).
2. **Profile.save — не сохраняется.** Toast показывается, в БД ничего не пишется. Нужен ресурс `users` + связка с авторизованным юзером.
3. **Notifications — статичные.** 7 элементов из `mock.ts`. Либо подключить к API, либо удалить раздел.

### Качество

4. **Tests** — нет. Кандидаты на unit-тесты (чистые функции):
   - `validateDetails` в `Booking.tsx`
   - `validate` в `ServiceForm.tsx`
   - `buildIcsBlob` в `utils/ics.ts`
   - `addMinutesHHMM`, `toMinutes`, `initialsFrom` в `Booking.tsx`
   - Все функции в `utils/date.ts`
   - `matchesServiceQuery` (в нескольких местах)
     Vitest рекомендую.
5. **Error Boundary** — нет. Сейчас исключение в любом компоненте = белый экран.
6. **CI / GitHub Actions** — нет. Должно быть `tsc --noEmit` + `npm run build` на каждый push.
7. **Code splitting** — нет. Bundle ~270KB одним файлом. `React.lazy()` для роутов даст −40%.

### Бизнес-фичи

8. **Email-уведомления** — после создания/отмены брони. Реально работает только с настоящим бэком.
9. **Несколько провайдеров услуг** — сейчас «Emily Martinez» захардкожен в детальных страницах.
10. **Time-blocks** — «я в отпуске» периоды должны блокировать слоты целиком.
11. **Часовые пояса** — критично для международных клиентов.
12. **Recurring bookings** — «каждый понедельник на 4 недели».

### Polish

13. **Mobile responsiveness** — десктоп-only. Sidebar 240px, calendar разваливается. Нужен drawer-pattern.
14. **Stat карточка "Cancellations"** — инверсия цвета через hack `!down`. Лучше расширить `<Stat>` пропом `invertSign`.
15. **Dead-translations** — после переделок остались неиспользуемые ключи (`booking.chooseCategory`, `booking.categoryServices`, `booking.backToCategories`, `booking.searchInCategory`, `booking.noServicesInCategory`). Можно почистить.
16. **Theme на runtime-смену системы** — слушаем только при init, `matchMedia.addEventListener('change')` решит.
17. **`bookings` экспорт** в `mock.ts` (если ещё остался) — должен быть удалён, не используется.

---

## 7. Инструкции запуска

```bash
cd slottr-app
npm install
npm run dev:all       # Vite (:5173) + JSON Server (:3001)
```

**Полезные команды:**

- `npm run dev` — только фронт (без бэка)
- `npm run server` — только JSON Server
- `npm run build` — production-сборка в `dist/`
- `npm run preview` — preview прод-сборки
- `./node_modules/.bin/tsc --noEmit` — проверка типов без эмита

---

## 8. Соглашения при работе с пользователем

В этой сессии пользователь общается по-русски, но просит англоязычные комментарии в коде (по обстоятельствам). Стиль работы:

1. **Перед кодом — план и push-back.** Объяснить tradeoffs, не угадывать.
2. **Уточнять через ask_user** если задача двусмысленна.
3. **Surgical changes** — менять только то что просили. Не «улучшать» соседнее.
4. **Verify обязательно** — `tsc --noEmit` + `npm run build` после каждого изменения.
5. **Класть файлы в `uploads/`** в той же структуре что в `src/` — пользователь скачивает и переписывает.
6. **Не плодить зависимости.** Был отказ от react-hook-form + zod в пользу нативной валидации после моего push-back.
7. **Senior-tone** — прямой, технически точный, без воды.

---

## 9. Известные хаки / технический долг

1. В `UI.tsx` Button — `void _v; void _s;` идиома для подавления `noUnusedLocals` при destructuring. Не баг, осознанно.
2. `confirmDialog` — module-level `externalAsk` переменная для не-React контекстов. Безопасно, но видимый код-смелл.
3. `notifications` в `mock.ts` — статичные, привязка к API не сделана.
4. В Dashboard stats для cancellations — инверсия цвета `!d.down` (хак).
5. Кнопка "Add to calendar" в детальных — работает, экспортирует .ics.
6. `<select>` для timezone в Profile — 3 хардкод-варианта, не из IANA database.

---

## 10. История ключевых решений

- **TypeScript** мигрировали постепенно в 3 этапа (foundation → utils/API → UI), чтобы build не ломался
- **react-hook-form + zod** установили → откатили на нативную валидацию (overkill для 1 формы)
- **Wizard для выбора услуги** (категория → услуга) пробовали → откатили на одностраничный sidebar+search (как в Services), пользователь так захотел для консистентности
- **Pill компонент** не пробрасывал className — починили после визуального бага
- **Кнопка "+ New booking"** была в двух местах (Dashboard header + topbar) → убрали с Dashboard
- **Проценты в Dashboard stats** заменили на абсолютные числа по запросу пользователя
- **Confirm/Toast** заменили все нативные `confirm()` / `alert()` для UX

---

Готов передавать. Удачи следующему агенту.
