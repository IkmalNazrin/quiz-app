# Architecture Overview - Quiz App

## 🚀 Core Philosophy
To build a high-performance, real-time quiz platform that is secure by design, server-authoritative, and resilient under load.

## 🏗️ Technical Stack
- **Frontend**: Flutter (Cross-platform)
- **Backend-as-a-Service**: Supabase
- **Realtime**: Supabase Realtime (WebSockets)
- **Edge Functions**: Deno (Typescript)
- **Database**: PostgreSQL with RLS (Row Level Security)

## Security Model

Security is baked into the architecture, not added as an afterthought:

1.  **Row Level Security (RLS)**: The database is the ultimate authority. RLS policies ensure users can only access their own data or public data.
2.  **Server-Authoritative Game Logic**: Game orchestration, scoring, and cheat detection happen in Edge Functions or PostgreSQL functions, not on the client.
3.  **Client Hardening**: We employ runtime checks (jailbreak/root detection, emulator detection via `DeviceIntegrityService`). **Note:** This is a *fail-closed* system; devices failing integrity checks are blocked at startup.
4.  **Rate Limiting**: Client-side network calls are guarded by a Token Bucket algorithm (`RateLimitedApiClient`), preventing API spam and accidental client-side DDoS.
5.  **Offline Sync Validation**: When the client syncs offline data, the backend meticulously validates timestamps and state transitions to prevent manipulation.

## 🔄 Core Data Flow (Game Loop)
1. **Host** triggers `start-round` via `game-orchestrator` Edge Function.
2. **Server** validates host authority, calculates `ends_at` timestamp, and updates DB.
3. **Realtime Service** broadcasts the new state to all **Participants**.
4. **Participants** submit answers directly to `game_answers` table (protected by RLS).
5. **Host** triggers `end-round`; **Server** tallies points and broadcasts results.

## 🧱 Architectural Boundaries (Anti-Corruption Layer)
To prevent code bloat and protect team velocity from third-party vendor changes:
*   **Directional Dependencies**: The UI layer depends on the App layer. The App layer depends on the Domain. The Infrastructure layer implements the Domain interfaces.
*   **No Direct Infrastructure Imports**: The Domain and UI layers *must not* import infrastructure packages directly (e.g., `package:supabase_flutter`). They must interact through interfaces defined in the Domain. 
    *   **Exception**: The DI layer (`app_providers.dart`) acts as the Architectural Composition Root and is the *only* place permitted to import concrete infrastructure vendors directly to bind them to domain interfaces.
- **Dependency Inversion**: All third-party dependencies must be wrapped in generic interfaces found in `lib/core/domain/interfaces/` and implemented in `lib/core/infrastructure/`.

## 🚒 Observability
- **Error Reporter**: Global Flutter error catching to `AppLogger`.
- **Performance Service**: API latency tracing for critical paths.
- **Health Checks**: Dedicated SQL RPCs for backend monitoring.
