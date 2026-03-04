-- ==========================================
-- Migration: Server Authoritative Game Logic
-- ==========================================
-- (Simplified for restoration)
ALTER TABLE public.game_sessions ADD COLUMN IF NOT EXISTS current_question_index INTEGER DEFAULT 0;
ALTER TABLE public.game_answers ADD COLUMN IF NOT EXISTS question_index INTEGER NOT NULL;
