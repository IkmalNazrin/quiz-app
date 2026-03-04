# ADR 006: PostgREST Join Optimization & Schema Alignment

## Status
Accepted

## Context
The "Browse Quizzes" and "Leaderboard" screens were suffering from missing data:
1. **Creator names** were missing because the `quizzes` table lacked a foreign key relationship to the `profiles` table that PostgREST could use for joined queries.
2. **Question counts** and **Leaderboard scores** were returning empty lists even when data existed in the database.

## Decision
1. **Explicit Foreign Keys**: We decided to explicitly define foreign key relationships in the `seed_data.sql` script to bypass Supabase's schema cache limitations and satisfy PostgREST join Requirements.
   ```sql
   ALTER TABLE public.quizzes ADD CONSTRAINT quizzes_owner_id_fkey 
   FOREIGN KEY (owner_id) REFERENCES public.profiles(id) ON DELETE CASCADE;
   ```
2. **Explicit Join Aliases**: To prevent mapping errors in the Data layer, all remote data sources must use explicit aliases for joined tables in `.select()` calls.
   - Example: `.select('*, profiles:owner_id(username)')`
3. **Public Read Policies (RLS)**: Enforced Row Level Security (RLS) policies for all public data tables (`quizzes`, `questions`, `leaderboard`) to ensure predictable cross-platform data visibility.

## Consequences
- **Pros**: Ensures 100% data visibility across individual and team queries; decoupled mapping names from DB column names where necessary.
- **Cons**: Requires manual SQL migrations when adding new entities that require joins.
- **Next Steps**: Re-verify "Host" flow to ensure questions are correctly passed to the game session.
