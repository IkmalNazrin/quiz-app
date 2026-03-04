-- ==========================================
-- Migration: Performance Optimization
-- ==========================================
CREATE INDEX IF NOT EXISTS idx_quizzes_owner ON public.quizzes(owner_id);
