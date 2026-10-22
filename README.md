# ⚡ Sting – The Social Media for Real Life

> *"Live it. Don't fake it."*

Sting is an authenticity-first social media platform where users complete one meaningful challenge every day and share proof through an **Unfiltered** post. Every post is captured live inside the app with zero gallery uploads and zero filters.

Designed with a high-end **Midnight Obsidian & Royal Violet** aesthetic featuring ambient mesh glows, floating glass capsule navigation, live avatar constellations, and spectrum performance meters.

---

## 📱 Mobile APK Download

You can download and install the Sting mobile app directly on any Android device:

- **Option 1 (GitHub Releases):** Go to [Releases](https://github.com/aathiran11/sting/releases) and download `app-release.apk`.
- **Option 2 (Local Build):** Found in `sting_flutter/build/app/outputs/flutter-apk/`.

### How to Install on Android:
1. Download `app-release.apk` on your Android phone.
2. Open the downloaded file.
3. If prompted, allow *"Install from unknown sources"* in your phone settings.
4. Tap **Install** and open Sting!

---

## 🛠 Project Structure

```
sting/
├── .github/workflows/      # Automated CI/CD pipeline to build & release APK
├── sting_backend/          # Node.js + Express + PostgreSQL API backend
│   ├── src/
│   │   ├── routes/         # Auth, feed, tasks, leaderboard, 1v1 challenges
│   │   ├── middleware/     # JWT authentication middleware
│   │   └── server.js       # Express server entry point
│   ├── Dockerfile          # Production Docker container
│   ├── Procfile            # Cloud deployment config (Heroku/Railway)
│   └── package.json
└── sting_flutter/          # Flutter mobile application
    ├── lib/
    │   ├── models/         # User, post, leaderboard, streak tier models
    │   ├── screens/        # Feed, discover, leaderboard, camera, profile
    │   ├── services/       # REST API client & motion verification
    │   ├── theme.dart      # Obsidian violet glass design tokens
    │   └── widgets/        # Constellation, spectrum bar, floating dock
    └── pubspec.yaml
```

---

## 🚀 Running Locally

### 1. Backend Server
```bash
cd sting_backend
npm install
npm run dev
```
The server will run on `http://localhost:4000`.

### 2. Flutter Mobile App
```bash
cd sting_flutter
flutter pub get
flutter run
```

---

## ☁️ Deployment

### Backend (Render / Railway / Fly.io / Heroku)
- Connect your GitHub repository (`aathiran11/sting`).
- Point the root directory to `sting_backend`.
- Build Command: `npm install`
- Start Command: `npm start`
- Environment Variables:
  - `PORT=4000`
  - `DATABASE_URL=<your-postgres-url>`
  - `JWT_SECRET=<your-secret>`

### Mobile App (Automated via GitHub Actions)
Every push to `main` / `master` automatically triggers the GitHub Actions workflow in [`.github/workflows/build-apk.yml`](.github/workflows/build-apk.yml) which builds the production APK and attaches it to GitHub Releases.
