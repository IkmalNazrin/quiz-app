-- ==========================================
-- Migration: Unique constraint on game_answers
-- Purpose: Prevent duplicate answer submissions per question
-- ==========================================

-- Clean up any existing duplicates before applying the constraint (keep the first submission)
DELETE FROM public.game_answers
WHERE id NOT IN (
    SELECT MIN(id)
    FROM public.game_answers
    GROUP BY session_id, user_id, question_index
);

ALTER TABLE public.game_answers
ADD CONSTRAINT game_answers_unique_submission UNIQUE (session_id, user_id, question_index);
