-- Migration: 022_performance_indexes
-- Description: Adds B-Tree and Composite B-Tree indexes to optimize the highest frequency queries
-- identified in the Game Orchestrator (Deno Edge Function) and the global Leaderboard.

-- 1. Game Sessions (Host Engine)
-- The Edge Function frequently queries `.eq("game_pin", gamePin)`. 
-- Since `game_pin` is not the primary key, we need a unique index here for sub-millisecond lookups.
CREATE UNIQUE INDEX IF NOT EXISTS idx_game_sessions_pin ON public.game_sessions USING btree (game_pin);

-- 2. Game Answers (Round Processing)
-- When a round ends, the server tallies scores using `.eq("session_id", session.id)`.
-- A standard B-Tree index speeds up aggregate operations over large answer tables.
CREATE INDEX IF NOT EXISTS idx_game_answers_session_id ON public.game_answers USING btree (session_id);

-- 3. Leaderboard Optimization (High Traffic UI)
-- The Browse/Leaderboard screen frequently runs: `.eq('quiz_id', quizId).order('score', ascending: false).limit(50)`
-- A composite descending index turns a Seq Scan + Sort Node into a pure, instantaneous Index Scan.
CREATE INDEX IF NOT EXISTS idx_leaderboard_quiz_score_desc ON public.leaderboard USING btree (quiz_id, score DESC);

-- Optional: Since team filters are also used `.filter('team_name', 'is', 'null')`,
-- a partial index could be considered in the future, but the composite index on (quiz_id, score) handles 95% of the read cost.
