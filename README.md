# Quiz App

A modern, real-time multiplayer quiz application built with Flutter and Supabase.

## Quick Start

**📁 Main Project:** See [quiz_app/README.md](./quiz_app/README.md) for full documentation.

### Setup
```bash
cd quiz_app
cp .env.example .env  # Add your Supabase credentials
flutter pub get
flutter run
```

## Features

✨ **Real-time Multiplayer** – Live quiz sessions with instant synchronization  
🔐 **Secure Auth** – Supabase authentication with device integrity checks  
🎮 **Gamified** – Points, streaks, achievements, and leaderboards  
📱 **Cross-Platform** – iOS, Android, Web, macOS, Linux, Windows  
⚡ **Offline Ready** – Actions queue and sync when connectivity returns  

## Architecture

- **Frontend:** Flutter + Riverpod + go_router
- **Backend:** Supabase (PostgreSQL, RLS, Realtime, Edge Functions)
- **Infrastructure:** Drift (local DB), Firebase App Check, Deno
- **Pattern:** Clean Architecture (Domain ← Infrastructure ← Features)

## Documentation

- 📖 **[Full README](./quiz_app/README.md)** – Setup, development, troubleshooting
- 🏗️ **[Architecture](./quiz_app/docs/ARCHITECTURE.md)** – Design decisions and patterns
- 📋 **[ADRs](./quiz_app/docs/adr/)** – Architecture Decision Records

## Development

```bash
# Install dependencies
cd quiz_app && flutter pub get

# Code generation
flutter pub run build_runner build --delete-conflicting-outputs

# Code quality
flutter analyze
dart format lib/

# Run tests
flutter test

# Monorepo commands
melos bootstrap  # Initialize packages
melos run analyze
melos run format
```

## Tech Stack

| Layer | Technology |
|-------|------------|
| **Frontend** | Flutter, Dart, Riverpod, go_router |
| **State** | Riverpod, Drift (SQLite) |
| **Backend** | Supabase, PostgreSQL, Deno |
| **Auth** | Supabase Auth, Firebase App Check |
| **Realtime** | Supabase Realtime (channels, presence) |
| **Design** | Material 3, Custom widgets |

## Security

🔒 Secrets managed via `.env` (never committed)  
🔒 Database enforces RLS (Row-Level Security)  
🔒 Firebase App Check verifies device integrity  
🔒 Server-authoritative game logic (edge functions)  
🔒 Build artifacts git-ignored  

## Project Structure

```
quiz_app/                    # Main Flutter application
├── lib/                     # App code
├── packages/                # Monorepo packages (domain, infrastructure, features, ui_core)
├── docs/                    # Architecture and documentation
└── ...platform configs      # iOS, Android, Web, etc.

supabase/                    # Database migrations & edge functions
```

## Support

For detailed information, see [quiz_app/README.md](./quiz_app/README.md)

## License

MIT License – See LICENSE file for details.