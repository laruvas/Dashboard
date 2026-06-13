# Slottr — Appointment Scheduler

[![Maintainability](https://qlty.sh/gh/laruvas/projects/Dashboard/maintainability.svg)](https://qlty.sh/gh/laruvas/projects/Dashboard)
[![TypeScript](https://img.shields.io/badge/TypeScript-strict-3178c6?logo=typescript&logoColor=white)](https://www.typescriptlang.org/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

Single-tenant приложение для записи клиентов на услуги. Каждый зарегистрированный пользователь управляет своим календарём: создаёт услуги, принимает бронирования, настраивает рабочие часы. Поддержка двух языков (RU/EN), тёмной/светлой темы, экспорт записей в iCal.

**Проект из каталога:** [Build an Appointment Scheduler](https://hackernoon.com/build-an-appointment-scheduler-using-react-twilio-and-cosmic-js-95377f6d1040)

## 🌐 Деплой

https://dashboard-ebon-six-38.vercel.app


## 🔐 Тестовый аккаунт

| Email | Password |
|---|---|
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
