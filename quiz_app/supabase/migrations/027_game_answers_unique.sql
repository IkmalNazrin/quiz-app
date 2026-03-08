-- ==========================================
-- Migration: Unique constraint on game_answers
-- Purpose: Prevent duplicate answer submissions per question
-- ==========================================

-- Clean up any existing duplicates before applying the constraint (keep one per group)
DELETE FROM public.game_answers ga
WHERE EXISTS (
    SELECT 1 FROM public.game_answers ga2
    WHERE ga2.session_id = ga.session_id
    AND ga2.user_id = ga.user_id
    AND ga2.question_index = ga.question_index
    AND ga2.ctid < ga.ctid
);

ALTER TABLE public.game_answers
ADD CONSTRAINT game_answers_unique_submission UNIQUE (session_id, user_id, question_index);
