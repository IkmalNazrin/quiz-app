-- Atomic score increment for game participants
-- Defends against read-then-write race conditions when multiple rapid answers are submitted.
CREATE OR REPLACE FUNCTION increment_participant_score(
  p_session_id UUID,
  p_user_id UUID,
  p_points INTEGER
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  UPDATE game_participants
  SET score = COALESCE(score, 0) + p_points
  WHERE session_id = p_session_id AND user_id = p_user_id;
END;
$$;
