# Quiz App

A modern, real-time multiplayer quiz application built with Flutter and Supabase. Features server-authoritative game logic, real-time synchronization, and a gamified user experience.

## Overview

Quiz App is a full-featured quiz platform that supports:
- **Real-time Multiplayer Gameplay** – Host-driven quiz sessions with live question delivery and instant result aggregation
- **User Authentication** – Secure sign-in via Supabase Auth with email verification and profile management
- **Server-Authoritative Logic** – Edge functions (Deno) enforce game rules and prevent cheating
- **Offline Support** – Queued actions sync when connectivity returns
- **Gamification** – Points, streaks, achievements, and leaderboards
- **Device Integrity** – Firebase App Check ensures only legitimate devices access the backend

## Tech Stack

### Frontend
- **Framework:** Flutter (Dart)
- **State Management:** Riverpod
- **Navigation:** go_router
- **Local Storage:** Drift (SQLite)
- **Design System:** Custom Material 3-based widgets

### Backend
- **Authentication & Realtime:** Supabase
- **Database:** PostgreSQL with Row-Level Security (RLS)
- **Edge Functions:** Deno-based server logic
- **Integrity:** Firebase App Check
- **Storage:** Supabase Storage for assets

### Architecture
- **Pattern:** Clean Architecture with Domain → Infrastructure → Features layers
- **Dependency Injection:** Riverpod providers
- **Realtime Communication:** Supabase Realtime channels (presence, broadcast)

## Project Structure

```
quiz_app/
├── lib/
│   ├── main.dart                  # App entry point
│   └── core/
│       ├── injection/             # DI composition root (Riverpod providers)
│       ├── router/                # Navigation & route definitions
│       └── constants/             # App-wide constants
├── packages/
│   ├── quiz_domain/               # Entities, repositories (interfaces), use-cases
│   ├── quiz_infrastructure/       # Supabase clients, DB, services implementations
│   ├── quiz_features/             # Feature screens, state notifiers
│   └── quiz_ui_core/              # Design system, reusable widgets
├── supabase/                       # Database migrations, RLS policies, edge functions
├── android/                        # Android platform configuration
├── ios/                            # iOS platform configuration
├── web/                            # Web platform configuration
└── docs/
    ├── ARCHITECTURE.md             # Detailed architecture decisions
    └── adr/                        # Architecture Decision Records
```

## Getting Started

### Prerequisites
- Flutter SDK (latest stable)
- Dart 3.0+
- iOS: Xcode 14+ (macOS)
- Android: Android Studio / SDK 21+
- Supabase account (https://supabase.com)
- Firebase project with App Check enabled

### Setup

1. **Clone the repository:**
   ```bash
   git clone https://github.com/IkmalNazrin/quiz-app.git
   cd quiz_app
   ```

2. **Configure environment:**
   ```bash
   cp .env.example .env
   ```
   Edit `.env` and add your Supabase credentials:
   ```
   SUPABASE_URL=https://your-project.supabase.co
   SUPABASE_ANON_KEY=your-anon-key
   ```

3. **Install dependencies:**
   ```bash
   flutter pub get
   ```
   For monorepo packages, also run:
   ```bash
   melos bootstrap
   ```

4. **Run the app:**
   ```bash
   flutter run
   ```

## Development

### Project Conventions
- **Naming:** Follow Dart style guide for naming (camelCase for variables/methods, PascalCase for classes)
- **Architecture:** See [ARCHITECTURE.md](./docs/ARCHITECTURE.md) for detailed patterns and decisions
- **Database Migrations:** Add new migrations to `supabase/migrations/`
- **Edge Functions:** Implement server logic in `supabase/functions/`

### Common Tasks

**Run tests:**
```bash
flutter test
```

**Generate code (Riverpod, Drift, etc.):**
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

**Check code quality:**
```bash
flutter analyze
dart format lib/
```

**Format and fix with melos:**
```bash
melos run analyze
melos run format
```

## Security & Secrets

- **Never commit `.env` files** – only `.env.example` should be tracked
- **Firebase Config:** `android/app/google-services.json` is git-ignored
- **Supabase RLS:** All database access enforces row-level security policies
- **App Check:** Verified device integrity before accessing backend

## Troubleshooting

### Large Build Artifacts
The project uses `.gitignore` to exclude build cache and test artifacts. If you encounter Git warnings about large files, ensure:
```bash
git status  # Verify build/ directories are untracked
```

### Dependency Issues
If packages fail to resolve:
```bash
flutter clean
flutter pub get
melos bootstrap  # if using monorepo
```

### Supabase Connection
Verify credentials in `.env` and check Supabase project settings:
- Confirm API URL matches `SUPABASE_URL`
- Ensure anonymous key has correct Row-Level Security policies

## Contributing

1. Create a feature branch: `git checkout -b feature/your-feature`
2. Commit changes with clear messages
3. Push to your fork and open a Pull Request
4. Ensure tests pass and code is analyzed

## Resources

- [ARCHITECTURE.md](./docs/ARCHITECTURE.md) – Architectural patterns and decisions
- [docs/adr/](./docs/adr/) – Architecture Decision Records for major design choices
- [Flutter Documentation](https://docs.flutter.dev/)
- [Supabase Documentation](https://supabase.com/docs)
- [Riverpod Guide](https://riverpod.dev/)

## License

This project is licensed under the MIT License – see LICENSE file for details.
