# Sting Backend — Node.js + Express + PostgreSQL

Covers Phase 1-3: auth (register/OTP/login/forgot password), profiles,
follow graph, daily task, and Unfiltered posts with real streak logic.

## 1. Install prerequisites (one-time)

- **Node.js** (LTS, v18+): https://nodejs.org — check with `node -v`
- **PostgreSQL** (v14+): https://www.postgresql.org/download/windows/
  During install it'll ask you to set a password for the `postgres`
  superuser — remember it.

## 2. Create the database (PowerShell)

Open PowerShell and connect using `psql` (installed alongside Postgres;
you may need to add it to PATH, e.g.
`C:\Program Files\PostgreSQL\16\bin`):

```powershell
psql -U postgres
```
Then inside the `psql` prompt:
```sql
CREATE DATABASE sting_db;
CREATE USER sting_user WITH PASSWORD 'sting_pass';
GRANT ALL PRIVILEGES ON DATABASE sting_db TO sting_user;
\q
```
(Change the password to something real if this will ever touch the
internet — the default here is just for local dev.)

## 3. Set up the project

Unzip this folder, then in PowerShell:
```powershell
cd path\to\sting_backend
npm install
copy .env.example .env
```
Open `.env` and adjust `DATABASE_URL` if you changed the db name/user/
password above, and change `JWT_SECRET` to a random string.

Run the migration to create tables:
```powershell
npm run migrate
```

Start the server:
```powershell
npm run dev
```
It runs at `http://localhost:4000`. Check it's alive:
```powershell
curl http://localhost:4000/api/health
```

## 4. Connect the Flutter app to this backend

Right now the Flutter app (`sting_flutter`) keeps everything in memory.
To wire it up you'd replace the in-memory `AppState` calls with HTTP
requests to these endpoints using the `http` package. That's the natural
next step once you're ready — happy to do that wiring next.

If you're testing on a **physical phone** on the same Wi-Fi as your PC,
use your PC's local IP instead of `localhost` (e.g.
`http://192.168.1.23:4000`) — find it with `ipconfig` in PowerShell. If
you're testing on the **Android emulator**, use `http://10.0.2.2:4000`,
which is the emulator's alias for your PC's localhost.

## API reference

### Auth
| Method | Path | Body | Notes |
|---|---|---|---|
| POST | `/api/auth/register` | `{ email or phone, password }` | Sends a 4-digit OTP (logged to the server console in dev — no SMS/email provider wired up yet) |
| POST | `/api/auth/verify-otp` | `{ contact, code }` | Creates the account, returns a JWT |
| POST | `/api/auth/login` | `{ emailOrUsername, password }` | Returns a JWT |
| POST | `/api/auth/forgot-password` | `{ email }` | Sends a reset code (logged to console) |
| GET | `/api/auth/check-username/:username` | — | `{ available: bool }` |

### Users (all except GET need `Authorization: Bearer <token>`)
| Method | Path | Notes |
|---|---|---|
| GET | `/api/users/me` | Your profile |
| PUT | `/api/users/me` | Update `username`/`name`/`bio`/`interest`/`isPrivate` |
| GET | `/api/users/:username` | Public profile |

### Follow graph
| Method | Path | Notes |
|---|---|---|
| POST | `/api/follow/:username` | Follow (auth) |
| DELETE | `/api/follow/:username` | Unfollow (auth) |
| GET | `/api/follow/:username/following` | Public |
| GET | `/api/follow/:username/followers` | Public |
| GET | `/api/follow/suggested/for-me` | Auth — same-interest users you don't follow |

### Daily task
| Method | Path | Notes |
|---|---|---|
| GET | `/api/tasks/today` | Same task for everyone that calendar day, persisted in `daily_tasks` |

### Posts & feed
| Method | Path | Notes |
|---|---|---|
| POST | `/api/posts` | Auth, multipart form: `image`, `taskLabel`, `caption`, `verifiedLive`, `capturedAt`. Enforces one post per calendar day and updates the streak server-side. |
| GET | `/api/posts/me` | Auth — your own posts |
| POST | `/api/posts/:id/like` / `DELETE .../like` | Auth |
| GET | `/api/feed` | Auth — posts from people you follow, or trending if you follow no one |

## What's real vs. still missing

- Passwords are hashed with bcrypt, JWT auth is wired throughout, and the
  streak logic lives server-side (`src/utils/streak.js`) so it can't be
  spoofed by the client.
- **OTP delivery is stubbed** — codes are logged to the server console,
  not actually texted/emailed. Wiring a real provider (Twilio, AWS SES,
  etc.) is a small, isolated change to `routes/auth.js` when you're ready.
- **"Live capture verified" is still trusted from the client** — the
  Flutter app's motion-sensor check happens on-device and the backend
  just stores whatever it's told. A determined user could send
  `verifiedLive: true` directly to the API. Real anti-fraud (Phase 6 in
  the roadmap) needs server-side signal, e.g. requiring the raw sensor
  samples and re-checking them here, or a signed attestation from the
  OS's device-integrity APIs.
- Uploaded images are stored on local disk under `/uploads` — fine for
  development, but you'll want to move this to S3/Cloudinary (as in the
  original roadmap) before any real deployment, since a server restart
  or redeploy can wipe local disk depending on your host.
- No rate limiting, no email verification enforcement, no admin/moderation
  endpoints yet — those come later in the roadmap (Phase 6/12).
