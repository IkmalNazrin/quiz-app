-- ==========================================
-- Migration: 031_game_answers_audit_columns
-- Date: 2026-03-08
-- Description: Adds answer_index and points columns to game_answers
--   for per-answer audit trail, dispute resolution, and per-question analytics.
--   Previously, only is_correct (boolean) was stored; the actual answer selected
--   by the user and the points awarded were lost after each round.
-- Related ADR: ADR-026 (Security Remediation)
-- ==========================================

-- 1. Add the selected answer index
--    Nullable initially to avoid breaking existing rows (historical data has no value).
ALTER TABLE public.game_answers
  ADD COLUMN IF NOT EXISTS answer_index INTEGER;

-- 2. Add the points awarded for this answer
--    Defaults to 0 for historical rows.
ALTER TABLE public.game_answers
  ADD COLUMN IF NOT EXISTS points INTEGER NOT NULL DEFAULT 0;

-- 3. Composite index for per-question analytics queries:
--    "How many users picked each answer option for question N in session S?"
--    Powers future analytics dashboards and cheat detection heuristics.
CREATE INDEX IF NOT EXISTS idx_game_answers_question_analysis
  ON public.game_answers (session_id, question_index, answer_index);
