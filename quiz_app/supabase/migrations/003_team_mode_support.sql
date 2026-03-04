-- ==========================================
-- Migration: Team Mode Support
-- ==========================================
ALTER TABLE public.game_sessions ADD COLUMN IF NOT EXISTS is_team_mode BOOLEAN DEFAULT false;
ALTER TABLE public.game_sessions ADD COLUMN IF NOT EXISTS teams JSONB DEFAULT '{}';
