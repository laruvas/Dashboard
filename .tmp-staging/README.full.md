# Slottr — Appointment Scheduler

> Single-tenant приложение для управления услугами и записями клиентов.
> Каждый зарегистрированный пользователь ведёт свой собственный календарь:
> создаёт услуги, принимает бронирования, отслеживает расписание.

**Стек:** React 18 + TypeScript · Vite · Express · SQLite · JWT (access + refresh)

---

## 📦 Что внутри

- **Auth** — регистрация, логин, JWT с refresh token rotation, защищённые роуты
- **Услуги** — CRUD с двуязычными полями (RU/EN), категории, цена, длительность
- **Бронирования** — 4-шаговый flow, calendar picker, conflict detection
- **Доступность** — настройка рабочих часов по дням недели, серверная генерация слотов
- **Dashboard** — недельный календарь с адаптивной сеткой часов, метрики revenue/bookings
- **Уведомления** — auto-генерация при создании/отмене/переносе записи, unread-badge
- **Профиль** — редактирование данных, working hours per-day, темы (dark/light), языки (RU/EN)
- **iCal export** — скачивание .ics для добавления записи в Google Calendar / Apple Calendar
- **Command Palette** — ⌘K быстрый поиск по услугам и бронированиям

---

## 🚀 Запуск локально

### Требования
- Node.js 20+
- npm 10+

### Команды

```bash
# 1. Установка зависимостей
npm install

# 2. Запуск бэка + фронта одновременно
npm run dev:all
```

Откроется:
- Фронт: http://localhost:5173
- Бэк:   http://localhost:3001

База данных (`slottr.db`) создаётся автоматически при первом запуске.

### Другие команды

```bash
npm run dev          # только фронт (Vite)
npm run server       # только бэк (Express + SQLite)
npm run build        # production build фронта
npm run preview      # preview собранного фронта
npm run seed:users   # создать тестовых юзеров (см. ниже)
npm run migrate      # миграция из legacy db.json (если есть)
```

---

## 🔐 Тестовые учётные данные

После `npm run seed:users` (требуется запущенный бэк):

| Email | Password | Роль |
|---|---|---|
| `alex@slottr.app` | `demo1234` | provider |
| `maria@slottr.app` | `demo1234` | provider |

Или зарегистрируйте свой аккаунт через `/register`.

---

## 🏗 Архитектура

### Frontend
```
src/
├── App.tsx                  — routes (Welcome, Login, Register публичны)
├── main.tsx                 — provider hierarchy
├── components/              — UI-кит (Calendar, Modal, Toast, ...)
├── data/                    — API клиенты (fetch wrappers с auth)
├── i18n/                    — Settings + Auth contexts, translations
├── layouts/AppLayout.tsx    — sidebar + topbar + outlet
├── pages/                   — страницы (Dashboard, Booking, ...)
├── types/index.ts           — все доменные типы (strict TypeScript)
└── utils/                   — date/ics/role хелперы
```

### Backend
```
scripts/
├── server.mjs               — Express, все REST endpoints
├── db.mjs                   — SQLite connection, схема, row→API mappers
├── migrate-from-json.mjs    — миграция legacy данных
└── seed-users.mjs           — создание тестовых юзеров
```

### Схема БД (SQLite)
```
users           (id PK, email UNIQUE, passwordHash, name, displayName,
                 phone, timezone, bio, workingHours JSON, createdAt)
services        (id PK, providerId FK→users CASCADE, tag JSON, tone,
                 duration, price, name JSON, description JSON, createdAt)
bookings        (id PK, providerId FK→users CASCADE, customerId FK→users CASCADE,
                 serviceId FK→services SET NULL, dateISO, time, endTime,
                 durationMin, service snapshot, total, status, withName,
                 initials, customerEmail, customerPhone, notes, createdAt)
notifications   (id PK, userId FK→users CASCADE, kind, tone, params JSON,
                 unread, createdAt)
refresh_tokens  (id PK, userId FK→users CASCADE, tokenHash UNIQUE,
                 expiresAt, createdAt)
```

### Use Cases

**1. Specialist онбординг.** Регистрация → задание working hours в Profile → создание услуги → отправка ссылки клиенту (или ручная запись клиента в свой календарь).

**2. Запись клиента.** Specialist открывает «Новая запись» → выбирает услугу → дату/время (только свободные слоты) → вводит данные клиента → подтверждение + .ics в почту клиенту.

**3. Управление расписанием.** Просмотр Dashboard со статистикой и недельной сеткой → редактирование/перенос/отмена брони → автоматические уведомления в фид.

**4. Авторизация и безопасность.** Access token (15 мин) живёт в localStorage, refresh token (30 дней) ротируется при каждом использовании — украденный токен инвалидируется при следующем легитимном использовании.

### REST API

Все защищённые эндпоинты требуют `Authorization: Bearer <accessToken>`.

| Method | Path | Описание |
|---|---|---|
| POST | `/register` | Регистрация, возвращает `{accessToken, refreshToken, user}` |
| POST | `/login` | Логин, возвращает то же |
| POST | `/refresh` | Обмен refresh на новую пару (rotation) |
| POST | `/logout` | Инвалидация refresh token |
| GET | `/users/:id` | Профиль (только свой) |
| PATCH | `/users/:id` | Обновление профиля |
| GET | `/services` | Мои услуги |
| POST | `/services` | Создать услугу |
| GET/PATCH/DELETE | `/services/:id` | Чтение/обновление/удаление (owner only) |
| GET | `/bookings` | Мои бронирования |
| POST | `/bookings` | Создать бронирование |
| GET/PATCH/DELETE | `/bookings/:id` | Чтение/обновление/удаление |
| GET | `/availability/:providerId?date=&duration=` | Слоты на дату с учётом working hours и конфликтов |
| GET | `/notifications` | Лента уведомлений |
| PATCH | `/notifications/:id` | Mark as read/unread |
| POST | `/notifications/mark-all-read` | Bulk mark-as-read |
| DELETE | `/notifications/:id` | Удалить |

---

## 🎯 Таблица соответствия функций

См. [docs/TRACEABILITY.md](docs/TRACEABILITY.md) — функции → файлы → экраны.

---

## 🌐 Деплой

> **Ссылка на деплой:** _(заполняется после деплоя на Vercel + Railway)_

### Production checklist
- [ ] `JWT_SECRET` установлен в env (`openssl rand -hex 32`)
- [ ] `npm run build` собрался без ошибок
- [ ] SQLite файл бэкапится регулярно
- [ ] CORS origins ограничены доменом фронта (сейчас открыт для dev)

---

## 📐 Каталог пет-проектов

> **Ссылка на проект в каталоге:** _(заполняется студентом)_

---

## 🧪 Качество кода

- TypeScript strict mode (`tsc --noEmit` → 0 errors)
- Все компоненты типизированы, дискриминированные unions для полиморфных props
- ESLint без warnings
- i18n ключи строго типизированы (`TKey = keyof typeof translations.en`)

> Бейдж Code Climate появится после подключения репозитория к codeclimate.com.

---

## 📝 Лицензия

MIT
