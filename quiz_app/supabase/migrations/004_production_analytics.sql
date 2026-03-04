-- ==========================================
-- Migration: Production Analytics
-- ==========================================
-- (Simplified for restoration)
CREATE OR REPLACE VIEW public.v_question_performance AS
SELECT 
    session_id,
    question_index,
    COUNT(id) as total_responses
FROM public.game_answers
GROUP BY session_id, question_index;
