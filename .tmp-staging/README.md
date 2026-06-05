# Slottr — Appointment Scheduler (React + Vite)

Реализация дизайна **Variant 3 — Minimal Linear** на React 18 + Vite 5 + React Router 6.

## ✨ Что внутри

- ⚡ **Vite** — мгновенный hot-reload
- ⚛️ **React 18** + функциональные компоненты, хуки
- 🧭 **React Router 6** — навигация между экранами
- 🎨 **CSS-переменные** из дизайн-системы (без UI-фреймворков)
- 📦 9 готовых страниц + переиспользуемые компоненты
- 🗄 **JSON Server** в роли фейкового бэкенда (создание/чтение/удаление записей)

## 📂 Структура проекта

```
slottr-app/
├── index.html                  ← точка входа HTML
├── package.json                ← зависимости и скрипты
├── vite.config.js              ← конфиг Vite
├── db.json                     ← база данных JSON Server (bookings)
└── src/
    ├── main.jsx                ← bootstrap React + Router
    ├── App.jsx                 ← роуты приложения
    ├── styles/app.css          ← дизайн-система (CSS-переменные)
    ├── data/
    │   ├── mock.js             ← моковые данные (услуги, уведомления)
    │   └── bookingsApi.js      ← API-слой: list/create/delete bookings
    ├── components/
    │   ├── Icons.jsx           ← inline-SVG иконки
    │   ├── UI.jsx              ← Button, Card, Stat, Pill, Field, Avatar, Tabs...
    │   └── Calendar.jsx        ← интерактивный календарь
    ├── layouts/
    │   └── AppLayout.jsx       ← сайдбар + топбар (общая обёртка)
    └── pages/
        ├── Login.jsx
        ├── Dashboard.jsx
        ├── Booking.jsx         ← создаёт запись через API
        ├── Confirmation.jsx    ← читает lastBooking из sessionStorage
        ├── Services.jsx
        ├── ServiceDetail.jsx
        ├── Bookings.jsx        ← реальные данные + cancel
        ├── Notifications.jsx
        └── Profile.jsx
```

## 🚀 Пошаговый запуск

### Шаг 1. Установите Node.js (если ещё нет)

Нужна версия **18 или новее**. Скачайте с официального сайта: <https://nodejs.org/> (берите LTS).

Проверьте установку:
```bash
node --version    # должно показать v18.x.x или выше
npm --version
```

### Шаг 2. Перейдите в папку проекта

```bash
cd slottr-app
```

### Шаг 3. Установите зависимости

Выполните **один раз** при первом запуске:
```bash
npm install
```
Это создаст папку `node_modules/` (~150 МБ) и поставит React, Vite и React Router. Займёт 30–90 секунд.

### Шаг 4. Запустите фронт + бэкенд одной командой

```bash
npm run dev:all
```

Эта команда параллельно поднимает:
- **JSON Server** на `http://localhost:3001` (фейковый бэкенд)
- **Vite dev-сервер** на `http://localhost:5173` (приложение)

В терминале увидите примерно:
```
[0]   \{^_^}/ hi!
[0]   Resources
[0]   http://localhost:3001/bookings
[1]   VITE v5.4.0  ready in 312 ms
[1]   ➜  Local:   http://localhost:5173/
```

Браузер откроется автоматически. Если нет — откройте **http://localhost:5173**.

> 💡 Если хотите запустить только фронт без бэка — используйте `npm run dev` (но создание записей не будет работать).
> Только бэк — `npm run server`.

### Шаг 5. Проверьте интеграцию 🎉

1. Перейдите в **New booking** → выберите дату и время → нажмите **Continue →**
2. Запись создастся в `db.json` (откройте файл — там появится новая запись)
3. На странице **Confirmation** увидите детали записи с настоящим `#SLT-id` из БД
4. На странице **Bookings** все записи подтянутся из API. Можно нажать **Cancel** — запись удалится
5. Если вернётесь в **New booking** на ту же дату — этот слот будет **disabled** (нельзя забронировать дважды)

---

## 🧭 Доступные маршруты

| URL | Страница |
|---|---|
| `/login` | Экран входа |
| `/dashboard` | Главная со статистикой и недельным календарём |
| `/booking` | Создание записи (выбор даты и времени) |
| `/confirmation` | Подтверждение записи |
| `/services` | Список услуг |
| `/services/:id` | Детали услуги + букинг-виджет |
| `/bookings` | История всех записей |
| `/notifications` | Уведомления |
| `/profile` | Настройки профиля |

## 📜 Доступные команды

| Команда | Что делает |
|---|---|
| `npm run dev:all` | **Главная команда** — фронт + бэкенд параллельно |
| `npm run dev` | Только Vite dev-сервер (`http://localhost:5173`) |
| `npm run server` | Только JSON Server (`http://localhost:3001`) |
| `npm run build` | Production-сборка в папку `dist/` |
| `npm run preview` | Локальный просмотр production-сборки |

## 🗄 JSON Server — что это

JSON Server превращает обычный `db.json` в полноценный REST API за 30 секунд. Поддерживает GET/POST/PUT/PATCH/DELETE.

Доступные эндпоинты:
- `GET    http://localhost:3001/bookings` — список записей
- `POST   http://localhost:3001/bookings` — создать запись
- `DELETE http://localhost:3001/bookings/:id` — удалить запись
- `GET    http://localhost:3001/bookings/:id` — одна запись

Все эти запросы делает наш `src/data/bookingsApi.js`. Можете открыть http://localhost:3001/bookings прямо в браузере — увидите JSON.

Чтобы сбросить базу — просто очистите `db.json`:
```json
{ "bookings": [] }
```

## 🛠 Если возникли проблемы

**Ошибка `command not found: npm`**
→ Node.js не установлен. Вернитесь к шагу 1.

**Ошибка `EADDRINUSE: port 5173 already in use`**
→ Порт занят другим процессом. Измените порт в `vite.config.js` или остановите тот процесс.

**Что-то странно работает после установки**
→ Удалите `node_modules/` и `package-lock.json`, выполните `npm install` заново.

**Белый экран в браузере**
→ Откройте DevTools → Console и посмотрите ошибку. Чаще всего это опечатка в импорте.

**Ошибка "Could not connect to server" на /bookings**
→ JSON Server не запущен. Используйте `npm run dev:all` вместо `npm run dev`.

**Ошибка `CORS` при создании записи**
→ JSON Server по умолчанию разрешает CORS. Если ошибка — проверьте, что порт 3001 не занят и что в `bookingsApi.js` указан правильный URL.

## 🚢 Деплой в production

```bash
npm run build
```
Папку `dist/` можно залить на любой статический хостинг:
- **Vercel** — `vercel deploy` (или drag-n-drop)
- **Netlify** — `netlify deploy --prod --dir dist`
- **GitHub Pages** — закоммитить `dist/` в ветку `gh-pages`
- **Cloudflare Pages** — подключить репозиторий

## 🔌 Следующие шаги для разработки

1. **API-слой**: замените `src/data/mock.js` на реальные запросы (например, `fetch` или `axios`).
2. **Авторизация**: добавьте JWT/Cookie + защищённые роуты через `<ProtectedRoute>`.
3. **State management**: для больших объёмов данных подключите Zustand / Redux Toolkit / TanStack Query.
4. **Формы**: используйте `react-hook-form` + `zod` для валидации.
5. **Дата/время**: подключите `date-fns` или `dayjs` (сейчас используется нативный `Date`).
6. **Тесты**: добавьте Vitest + React Testing Library.
7. **TypeScript**: переименуйте `.jsx → .tsx`, добавьте `tsconfig.json` и `typescript` в devDeps.

## 🎨 Кастомизация

Все цвета и токены в одном месте — `src/styles/app.css`, секция `:root`. Поменяйте акцентный цвет:
```css
:root {
  --accent: #FF6B4A;        /* ← измените здесь */
  --accent-hover: #FF8268;
}
```
Изменения мгновенно применятся ко всему приложению.
