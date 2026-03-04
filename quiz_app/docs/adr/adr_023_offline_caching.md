# ADR 023: Local Caching & Offline Resilience

## Context
As the Quiz App scales, users may experience intermittent network connectivity issues or offline scenarios. Currently, the app relies on in-memory or secure-storage queues (e.g., `SyncQueueService` using `flutter_secure_storage`) for basic retry mechanisms, but it lacks a robust, queryable local caching layer for game data, histories, and profiles. We need a persistent local database to ensure zero data loss and to provide a seamless offline experience.

## Options Considered

### 1. Hive / SharedPreferences
- **Pros:** Lightweight, pure Dart, easy to set up for key-value pairs.
- **Cons:** Not suited for complex relational queries (e.g., finding all quizzes by a specific owner offline). No robust indexing.

### 2. Isar
- **Pros:** Highly performant NoSQL database, excellent Flutter integration, supports complex queries and indexes.
- **Cons:** Requires strict schema definition; migrating from NoSQL to relational mental models can sometimes be tricky when syncing with PostgREST (Supabase).

### 3. Drift (SQLite)
- **Pros:** Full-featured SQLite wrapper. Extremely robust. Provides type-safe SQL queries. Aligns perfectly with the relational structure of our Supabase backend (tables, joins, migrations). Can seamlessly handle offline data queuing for later sync.
- **Cons:** Requires code generation (`build_runner`), slightly steeper learning curve and setup boilerplate.

## Decision
We will adopt **Drift (Option 3)** as our local caching and offline resilience layer.

### Rationale
Our backend (Supabase) is inherently relational (PostgreSQL). By using Drift, we can maintain a similar relational mental model on the client side, making it easier to cache normalized data (e.g., `quizzes`, `questions`, `profiles`) without duplicating nested JSON objects. Furthermore, analyzing the project requirements (as noted in earlier phase handovers) explicitly points towards a desired "SQLite solution" for reliable offline behavior.

### Implementation Strategy
1. **Add Dependencies:** `drift`, `sqlite3_flutter_libs`, `path_provider`, `path`. Add `drift_dev` to dev_dependencies.
2. **Schema Definition:** Define local tables corresponding to core entities (`LocalQuizzes`, `LocalQuestions`, `LocalSyncQueue`).
3. **Repository Pattern:** Update existing repositories to first query the Drift local database (cache), then verify with the remote data source in the background, or directly query remote and persist to local.
4. **Offline Sync:** Expand `SyncQueueService` to store failed mutations in Drift instead of secure storage, ensuring survival across OS terminations.

## Consequences
- **Positive:** True offline support; game data won't be lost on background termination. UI will load instantly from the cache.
- **Negative:** Increased app bundle size (due to SQLite binaries). The build step (`build_runner`) will take significantly longer.

## Status
Proposed
