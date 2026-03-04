# ADR 004: Data Seeding and Environment Validation

## Status
Proposed

## Context
As the QuizApp scales and moves towards a production-ready state, we need a reliable way to validate frontend features (Leaderboards, Challenges, Feed) that depend on multi-user interaction. Relying on a single test account is insufficient for verifying:
- UI responsiveness with many records (pagination, scrolling).
- Logic for ranking and streaks.
- "Social" features like 1v1 challenges.
- Data integrity across related tables.

## Decision
We will implement an **SQL-based Data Seeding Strategy**.

### Architecture Options Evaluated

| Option | Description | Pros | Cons |
| :--- | :--- | :--- | :--- |
| **1. UI-Level Mocking** | Intercept API calls and return mock JSON. | Fast, no backend dependency. | Misses integration bugs; database constraints are ignored. |
| **2. Client-Side Seed Logic** | Add a "Developer Menu" to generate data via Dart. | Easy to trigger during dev. | Risky if accidentally shipped; complex to handle `auth.users` constraints. |
| **3. SQL Seed Scripts** | Standardized SQL for `auth` and `public` schemas. | **Reproducible, respects DB constraints, simulates real production data accurately.** | Requires access to Supabase SQL editor/CLI. |

### Chosen Option: 3. SQL Seed Scripts
We will create a comprehensive `seed_data.sql` script designed for the Supabase SQL Editor. This script will leverage standard SQL to populate both `auth.users` and their corresponding `public.profiles`, along with secondary data (quizzes, scores).

## Consequences
- **Positive**: High fidelity testing. We can simulate hundreds of users to catch edge cases in the UI layout.
- **Negative**: Maintainability cost; as the schema evolves, the seed script must be updated.

## Implementation Details
- Use `gen_random_uuid()` for IDs to avoid collisions.
- Populate `auth.users` with dummy emails (e.g., `user1@example.com`) to allow for future login testing if needed.
- Ensure `public.profiles` records are created for every `auth.user` to satisfy foreign keys.
- Generate a variety of scores and streaks to test the "Top Performers" and "Hot Streaks" sections.
