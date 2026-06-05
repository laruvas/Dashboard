# Таблица соответствия функций

Каждая функция приложения с указанием файлов в репозитории и страницы где она используется.

Базовые ссылки (при сдаче замените `BRANCH` на `main`):
- GitHub: `https://github.com/laruvas/Dashboard/tree/main/`
- Деплой: _(после деплоя)_

---

## 🔐 Авторизация

| Функция | Файлы | Страница |
|---|---|---|
| Регистрация нового пользователя | [`src/pages/Register.tsx`](../src/pages/Register.tsx), [`scripts/server.mjs`](../scripts/server.mjs) (POST /register) | `/register` |
| Вход в систему | [`src/pages/Login.tsx`](../src/pages/Login.tsx), [`scripts/server.mjs`](../scripts/server.mjs) (POST /login) | `/login` |
| Защищённые маршруты | [`src/components/ProtectedRoute.tsx`](../src/components/ProtectedRoute.tsx), [`src/App.tsx`](../src/App.tsx) | все `/dashboard`, `/services`, ... |
| JWT с refresh rotation | [`src/data/http.ts`](../src/data/http.ts), [`scripts/server.mjs`](../scripts/server.mjs) (POST /refresh) | прозрачно при истечении access |
| Logout с инвалидацией refresh | [`src/i18n/AuthContext.tsx`](../src/i18n/AuthContext.tsx), [`scripts/server.mjs`](../scripts/server.mjs) (POST /logout) | `/profile` → кнопка «Выйти» |
| Session probe при загрузке | [`src/i18n/AuthContext.tsx`](../src/i18n/AuthContext.tsx) | автоматически при первой загрузке |

## 👤 Профиль

| Функция | Файлы | Страница |
|---|---|---|
| Просмотр / редактирование профиля | [`src/pages/Profile.tsx`](../src/pages/Profile.tsx) | `/profile` |
| Working hours per-day editor | [`src/pages/Profile.tsx`](../src/pages/Profile.tsx) (`WorkingHoursEditor`) | `/profile` |
| Смена темы (dark/light) | [`src/i18n/SettingsContext.tsx`](../src/i18n/SettingsContext.tsx), [`src/components/Toggles.tsx`](../src/components/Toggles.tsx) | в любой странице, topbar |
| Смена языка (RU/EN) | те же файлы | topbar |

## 🛍 Услуги

| Функция | Файлы | Страница |
|---|---|---|
| Список услуг | [`src/pages/Services.tsx`](../src/pages/Services.tsx), [`src/data/servicesApi.ts`](../src/data/servicesApi.ts) | `/services` |
| Создание услуги (модалка) | [`src/components/ServiceForm.tsx`](../src/components/ServiceForm.tsx) | `/services` → «+ Добавить» |
| Редактирование услуги | те же файлы | `/services` → кнопка edit |
| Удаление услуги (с подтверждением) | [`src/components/Confirm.tsx`](../src/components/Confirm.tsx), [`src/pages/Services.tsx`](../src/pages/Services.tsx) | `/services` |
| Детальная страница услуги | [`src/pages/ServiceDetail.tsx`](../src/pages/ServiceDetail.tsx) | `/services/:id` |
| Фильтрация по тегам | [`src/pages/Services.tsx`](../src/pages/Services.tsx) | `/services` |
| Поиск по услугам | [`src/pages/Services.tsx`](../src/pages/Services.tsx) | `/services` |

## 📅 Бронирования

| Функция | Файлы | Страница |
|---|---|---|
| 4-шаговый booking flow | [`src/pages/Booking.tsx`](../src/pages/Booking.tsx) | `/booking` |
| Шаг 1: выбор услуги с фильтром/поиском | те же | `/booking` |
| Шаг 2: выбор даты в календаре | [`src/components/Calendar.tsx`](../src/components/Calendar.tsx) | `/booking` |
| Шаг 2: выбор слота с conflict detection | [`src/data/availabilityApi.ts`](../src/data/availabilityApi.ts), [`scripts/server.mjs`](../scripts/server.mjs) (`/availability`) | `/booking` |
| Шаг 3: данные клиента (валидация) | [`src/pages/Booking.tsx`](../src/pages/Booking.tsx) | `/booking` |
| Шаг 4: подтверждение + создание | [`src/data/bookingsApi.ts`](../src/data/bookingsApi.ts) | `/booking` |
| Confirmation page после создания | [`src/pages/Confirmation.tsx`](../src/pages/Confirmation.tsx) | `/confirmation` |
| Список бронирований | [`src/pages/Bookings.tsx`](../src/pages/Bookings.tsx) | `/bookings` |
| Status tabs (upcoming/past/cancelled) | те же | `/bookings` |
| Поиск по бронированиям | [`src/pages/Bookings.tsx`](../src/pages/Bookings.tsx) | `/bookings` |
| Перенос брони (modal) | [`src/components/RescheduleModal.tsx`](../src/components/RescheduleModal.tsx) | `/bookings` → «Изменить» |
| Отмена брони | [`src/pages/Bookings.tsx`](../src/pages/Bookings.tsx) | `/bookings` → «Отменить» |
| Удаление брони | [`src/pages/Bookings.tsx`](../src/pages/Bookings.tsx) | `/bookings` → «Удалить» |
| Детальная страница брони | [`src/pages/BookingDetail.tsx`](../src/pages/BookingDetail.tsx) | `/bookings/:id` |
| Экспорт в iCal (.ics) | [`src/utils/ics.ts`](../src/utils/ics.ts) | `/bookings/:id` → «Скачать .ics» |

## 📊 Dashboard

| Функция | Файлы | Страница |
|---|---|---|
| Метрики (today/week/revenue/cancellations) | [`src/pages/Dashboard.tsx`](../src/pages/Dashboard.tsx) | `/dashboard` |
| Динамика «vs вчера/прошлая неделя/месяц» | те же | `/dashboard` |
| Недельный календарь с адаптивной сеткой | те же | `/dashboard` |
| Навигация по неделям (prev/today/next) | те же | `/dashboard` |
| Upcoming bookings table | те же | `/dashboard` |

## 🔔 Уведомления

| Функция | Файлы | Страница |
|---|---|---|
| Auto-генерация при создании брони | [`scripts/server.mjs`](../scripts/server.mjs) (POST /bookings hook) | автоматически |
| Auto-генерация при отмене | [`scripts/server.mjs`](../scripts/server.mjs) (PATCH /bookings hook) | автоматически |
| Auto-генерация при переносе | те же | автоматически |
| Лента уведомлений | [`src/pages/Notifications.tsx`](../src/pages/Notifications.tsx), [`src/data/notificationsApi.ts`](../src/data/notificationsApi.ts) | `/notifications` |
| Mark as read (одно/все) | те же | `/notifications` |
| Relative time («5 мин назад») | [`src/pages/Notifications.tsx`](../src/pages/Notifications.tsx) | `/notifications` |
| Локализованные шаблоны | [`src/i18n/translations.ts`](../src/i18n/translations.ts) (`notif.kind.*`) | `/notifications` |

## 🎨 UX

| Функция | Файлы | Страница |
|---|---|---|
| Command Palette (⌘K) | [`src/components/CommandPalette.tsx`](../src/components/CommandPalette.tsx) | везде, hotkey ⌘K |
| Toast уведомления | [`src/components/Toast.tsx`](../src/components/Toast.tsx) | везде |
| Confirm dialogs (Promise-based) | [`src/components/Confirm.tsx`](../src/components/Confirm.tsx) | везде |
| Skeleton loaders (с 300ms задержкой) | [`src/components/Skeleton.tsx`](../src/components/Skeleton.tsx) | везде где есть loading |
| Empty states с иллюстрациями | [`src/components/EmptyState.tsx`](../src/components/EmptyState.tsx) | везде где пусто |
| Welcome / landing page | [`src/pages/Welcome.tsx`](../src/pages/Welcome.tsx) | `/` |
| Session expired toast | [`src/i18n/AuthContext.tsx`](../src/i18n/AuthContext.tsx), [`src/data/http.ts`](../src/data/http.ts) | при истечении сессии |

## 🛡 Безопасность

| Функция | Файлы | Где работает |
|---|---|---|
| JWT signature verification (HS256) | [`scripts/server.mjs`](../scripts/server.mjs) (`parseToken`) | каждый защищённый запрос |
| bcrypt password hashing (10 rounds) | [`scripts/server.mjs`](../scripts/server.mjs) (`/register`, `/login`) | при создании/логине |
| Refresh token hashing (SHA-256) | [`scripts/server.mjs`](../scripts/server.mjs) (`hashRefresh`) | в БД хранится только хеш |
| Refresh rotation (single-use) | [`scripts/server.mjs`](../scripts/server.mjs) (POST /refresh) | каждое использование выдаёт новую пару |
| Foreign keys with CASCADE | [`scripts/db.mjs`](../scripts/db.mjs) | удаление юзера → удаление его данных |
| Ownership checks на каждом endpoint | [`scripts/server.mjs`](../scripts/server.mjs) | provider может менять только свои услуги/брони |
| Per-user data isolation | [`scripts/server.mjs`](../scripts/server.mjs) | GET /services/bookings возвращает только свои |
