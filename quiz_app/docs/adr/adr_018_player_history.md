# ADR 018: Player History Architecture

## Status
Proposed

## Context
Users currently have no way to view their past game performance. While `game_participants` tracks this data in the database, it is not exposed to the UI. We need a scalable, performant way to show users their game history (scores, ranks, dates).

## Decision
We will implement **Player History** within the **Profile Feature**, leveraging existing relational data.

### 1. Data Source
- We will NOT create a new `history` table.
- We will query `game_participants` joined with `game_sessions` and `quizzes`.
- **Why?** Prevents data duplication. `game_participants` is already the immutable record of a play session.

### 2. Domain Modeling
- **Location**: `lib/features/profile/domain/entities/game_history_item.dart`
- **Fields**:
  - `quizTitle` (from Quizzes)
  - `score` (from Participants)
  - `rank` (calculated or stored? *Decision: Calculate dynamically or add `rank` column later. For now, show Score.*)
  - `playedAt` (from `joined_at` or `created_at`)
  - `sessionId` (for potentially viewing detailed report later)

### 3. UI Location
- **Profile Screen**: Add a "History" tab or section.
- **Dedicated Page**: `HistoryScreen` if the list is long, reachable from Profile.

### 4. Scalability Considerations
- Pagination is mandatory. `game_participants` will grow fast.
- Indexing: Ensure `user_id` on `game_participants` is indexed.

## Consequences
- **Positive**: Low storage overhead (uses existing data). Quick implementation.
- **Negative**: Complex query (joins) might be slow without proper indexing as data grows.

## Schema Changes
- None required immediately for MVP.
- Future: Add indexes if missing.
