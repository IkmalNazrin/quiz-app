# ADR 003: User Profile Architecture

## Status
Proposed

## Context
The QuizApp requires a way for users to view and manage their personal information and gamification progress (points, streaks, history). Currently, user data is split between Supabase Auth metadata and a partially implemented `profiles` table used for leaderboards.

## Decision
We will implement a dedicated **Profile Feature** following **Clean Architecture** principles.

### Architecture Options Evaluated

| Option | Description | Pros | Cons |
| :--- | :--- | :--- | :--- |
| **1. Integrated Profile** | Add profile logic to the existing `auth` feature. | Faster to implement, shared models. | Violates SRP, `auth` becomes a "god" module. |
| **2. Dedicated Feature** | Create `lib/features/profile` with its own Domain, Data, and Presentation layers. | **Highly maintainable, follows project patterns, scalable for future social features.** | More initial boilerplate. |
| **3. No Profile** | Rely solely on auth metadata and simple leaderboard records. | No implementation cost. | Poor UX for gamification, not suitable for enterprise production. |

### Chosen Option: 2. Dedicated Feature

We will create a new feature folder `lib/features/profile` to handle all user-specific data beyond core authentication.

## Consequences
- **Positive**: Clear separation of concerns. Easier to add achievements, follow/social systems, and detailed statistics later.
- **Negative**: Requires initial effort to set up the feature structure and migrate existing profile usage in `leaderboard`.

## Data Model
`ProfileEntity` will include:
- `id` (UUID)
- `username` (String)
- `fullName` (String?)
- `avatarUrl` (String?)
- `bio` (String?)
- `totalPoints` (Int)
- `currentStreak` (Int)
- `highestStreak` (Int)
- `createdAt` (DateTime)

## UI Integration
- A new `ProfileScreen` accessible via a profile icon in the `DashboardScreen` AppBar.
- Integration with the "Social" tab if needed for public profiles.
