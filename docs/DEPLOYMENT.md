# Deployment guide

> Цель: фронт на Vercel, бэк на Render, БД на Turso. Бесплатно, без карты.
> Время: ~20–30 минут.

## 0. Что нужно заранее

- GitHub аккаунт с pushed репозиторием (`github.com/laruvas/Dashboard`)
- Аккаунты: [Vercel](https://vercel.com), [Render](https://render.com), [Turso](https://turso.tech) — все через GitHub login
- Установленные локально: `git`, `node 20+`. Опционально `turso` CLI.

---

## 1. Turso — managed SQLite

### 1.1 Установка CLI

**macOS / Linux:**
```bash
curl -sSfL https://get.tur.so/install.sh | bash
```

**Windows (PowerShell):**
```powershell
irm get.tur.so/install.ps1 | iex
```

После установки перезапусти терминал.

### 1.2 Логин и создание БД

```bash
turso auth login                          # откроется браузер
turso db create slottr-prod --group default
turso db show slottr-prod --url           # → libsql://slottr-prod-laruvas.turso.io
turso db tokens create slottr-prod        # → eyJhbGciOi... (длинный токен)
```

**Сохрани оба значения** — понадобятся в Render.

### Альтернатива без CLI

Можешь создать БД через [веб-консоль Turso](https://turso.tech/app):
- New Database → имя `slottr-prod` → Create
- Открой её → tab «Connect» → скопируй URL
- tab «Tokens» → Generate Token → скопируй

---

## 2. Render — бэк

### 2.1 Подключение репо

1. Зайди в [Render Dashboard](https://dashboard.render.com)
2. **New → Web Service**
3. **Connect a repository** → выбери `laruvas/Dashboard`
4. Настройки:
   - **Name:** `slottr-api`
   - **Region:** Frankfurt (или ближайший)
   - **Branch:** `main`
   - **Runtime:** Node
   - **Build Command:** `npm install`
   - **Start Command:** `npm start`
   - **Plan:** Free

### 2.2 Environment variables

В разделе **Environment** добавь 4 переменные:

| Key | Value | Где взять |
|---|---|---|
| `JWT_SECRET` | (см. ниже) | `openssl rand -hex 32` в терминале |
| `CORS_ORIGIN` | `https://slottr-laruvas.vercel.app` | URL фронта (заполнишь после шага 3) |
| `TURSO_DATABASE_URL` | `libsql://...` | из `turso db show` |
| `TURSO_AUTH_TOKEN` | `eyJhbGci...` | из `turso db tokens create` |

Генерация JWT secret:
```bash
openssl rand -hex 32
# или прямо в node:
node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"
```

### 2.3 Deploy

Жми **Create Web Service**. Render склонирует репо, поставит зависимости, запустит сервер.
Через 2–4 минуты будет URL вида `https://slottr-api.onrender.com`.

Проверь:
```bash
curl https://slottr-api.onrender.com/healthz
# → {"ok":true}
```

### ⚠ Free tier особенность

Сервис **засыпает после 15 минут без запросов**. Первый запрос пробуждает (~30 сек cold start). На защите перед демо тыкни URL заранее, чтоб прогрелся.

---

## 3. Vercel — фронт

### 3.1 Импорт репо

1. [Vercel Dashboard](https://vercel.com/new)
2. **Import Git Repository** → выбери `laruvas/Dashboard`
3. Настройки:
   - **Framework Preset:** Vite (определит автоматически)
   - **Root Directory:** `./` (по умолчанию)
   - **Build Command:** `npm run build` (по умолчанию)
   - **Output Directory:** `dist` (по умолчанию)

### 3.2 Environment variables

Раздел **Environment Variables**:

| Key | Value |
|---|---|
| `VITE_API_URL` | `https://slottr-api.onrender.com` (без `/` в конце) |

### 3.3 Deploy

**Deploy**. Через ~1 минуту получишь URL вида `https://slottr-laruvas.vercel.app`.

### 3.4 Обновить CORS на Render

Вернись в Render → Environment → `CORS_ORIGIN` = URL фронта который только что получил. Сервис автоматически перезапустится.

---

## 4. Проверка

В режиме инкогнито открой URL фронта:

1. ✅ Видишь Welcome page
2. ✅ Регистрация / Логин работает (с задержкой на cold start)
3. ✅ Создание услуги сохраняется (после перезагрузки страницы — на месте)
4. ✅ DevTools → Network: запросы идут на `https://slottr-api.onrender.com`

### Если что-то не работает

| Симптом | Причина | Фикс |
|---|---|---|
| Network errors / CORS | `CORS_ORIGIN` не совпадает с URL фронта | Render → Environment → исправить |
| 401 при логине нового юзера | JWT secret поменялся, старые токены инвалидны | Очисти localStorage, залогинься заново |
| 500 на login/register | Turso credentials не работают | Проверь URL и token в Render env |
| Cold start > 1 минуты | Render free плана так и работает | На защите прогрей заранее, или upgrade на $7/мес |
| Не сохраняются данные между сессиями | Не подключен Turso, бэк пишет в локальный slottr.db (теряется при рестарте) | Убедись что `TURSO_DATABASE_URL` задан в Render env |

---

## 5. Обновление после изменений

```bash
git add .
git commit -m "feat: ..."
git push origin main
```

Vercel и Render автоматически пересоберут себя из коммита. ~2 минуты.

---

## 6. Тестовые credentials для проверяющих

Создай тестового юзера через UI на проде (`/register`) и пропиши в `README.md`:

```
Email:    test@slottr.app
Password: demo1234
```

Альтернатива — через `seed:users` скрипт после деплоя:
```bash
# Локально, указав prod-URL:
API_URL=https://slottr-api.onrender.com npm run seed:users
```
