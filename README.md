# Slottr — Build an Appointment Scheduler

[![Maintainability](https://qlty.sh/gh/laruvas/projects/Dashboard/maintainability.svg)](https://qlty.sh/gh/laruvas/projects/Dashboard)
[![Open Source Helpers](https://www.codetriage.com/laruvas/dashboard/badges/users.svg)](https://www.codetriage.com/laruvas/dashboard)
[![TypeScript](https://img.shields.io/badge/TypeScript-strict-3178c6?logo=typescript&logoColor=white)](https://www.typescriptlang.org/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

Single-tenant приложение для записи клиентов на услуги. Каждый зарегистрированный пользователь управляет своим календарём: создаёт услуги, принимает бронирования, настраивает рабочие часы. Поддержка двух языков (RU/EN), тёмной/светлой темы, экспорт записей в iCal.

**Проект из каталога:** [Build an Appointment Scheduler](https://hackernoon.com/build-an-appointment-scheduler-using-react-twilio-and-cosmic-js-95377f6d1040)

## 🌐 Деплой

https://dashboard-ebon-six-38.vercel.app

## ⚠️ Нюансы при открытии деплоя

Проект развёрнут на бесплатных тарифах Vercel / Render / Turso, поэтому при первом открытии могут быть небольшие задержки.

- **Первый запрос к backend может выполняться 20–40 секунд.**  
  Backend размещён на Render, и на бесплатном тарифе сервис может “засыпать” после периода неактивности. После первого запроса сервер просыпается, и дальнейшие действия работают быстрее.

- **Если страница деплоя не открывается или долго не грузится, попробуйте включить VPN.**  
  В некоторых сетях доступ к Vercel, Render или отдельным CDN-ресурсам может быть нестабильным. После включения VPN страница обычно открывается корректно.

- **Если после входа или регистрации данные не загрузились сразу, подождите несколько секунд и обновите страницу.**  
  Обычно это связано с холодным стартом backend.

- **Frontend и backend размещены отдельно.**  
  Frontend работает на Vercel, а API — на Render. Поэтому при проблемах с сетью или CORS-заголовками часть запросов может временно не пройти.

- **Тестовый аккаунт может содержать уже созданные данные.**  
  В нём могут быть услуги, записи и уведомления, оставшиеся после демонстрации или проверки проекта.

- **База данных используется облачная.**  
  Данные хранятся в Turso через libSQL/SQLite, поэтому они сохраняются между перезапусками backend.

- **Если API временно недоступен, интерфейс может показать пустые списки или ошибку загрузки.**  
  В таком случае стоит повторить действие через несколько секунд.

- **Для проверки лучше открывать сайт в режиме инкогнито.**  
  Так не будут мешать старые токены авторизации или сохранённые данные из localStorage.
  
## 🔐 Тестовый аккаунт

| Email             | Password |
| ----------------- | -------- |
| `admin@gmail.com` | `admin1` |

## 🛠 Стек

- **Frontend:** React 18, TypeScript (strict), Vite, React Router
- **Backend:** Node.js, Express, JWT (access + refresh rotation), bcryptjs
- **Database:** libSQL / SQLite (Turso в проде, локальный файл в dev)

## 🚀 Запуск локально

Требуется Node.js 20+.

```bash
npm install
npm run dev:all
```

- Фронт: http://localhost:5173
- Бэк: http://localhost:3001

База `slottr.db` создаётся автоматически при первом запуске.

## 📂 Дополнительно

- [`docs/TRACEABILITY.md`](docs/TRACEABILITY.md) — таблица соответствия функций
- [`docs/DEPLOYMENT.md`](docs/DEPLOYMENT.md) — пошаговый гайд по деплою
