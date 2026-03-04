-- Analytics Supplementary Tables
CREATE TABLE IF NOT EXISTS public.quiz_ratings (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  quiz_id uuid REFERENCES public.quizzes(id) ON DELETE CASCADE,
  user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE,
  rating numeric NOT NULL CHECK (rating >= 1 AND rating <= 5),
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  UNIQUE(quiz_id, user_id)
);

-- Analytics Indexes
CREATE INDEX IF NOT EXISTS idx_game_sessions_host_id ON public.game_sessions(host_id);
CREATE INDEX IF NOT EXISTS idx_game_sessions_quiz_id ON public.game_sessions(quiz_id);
CREATE INDEX IF NOT EXISTS idx_game_participants_session_id ON public.game_participants(session_id);
CREATE INDEX IF NOT EXISTS idx_quiz_ratings_quiz_id ON public.quiz_ratings(quiz_id);

-- RPC: Get Host Analytics Summary
CREATE OR REPLACE FUNCTION get_host_analytics_summary(host_uuid uuid)
RETURNS json
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  total_quizzes_count integer;
  total_plays_count integer;
  total_players_count integer;
  average_rating numeric;
  result json;
BEGIN
  -- 1. Total Quizzes owned by host
  SELECT COUNT(*) INTO total_quizzes_count
  FROM public.quizzes
  WHERE owner_id = host_uuid;

  -- 2. Total Plays (Sessions that are NOT in 'lobby' status)
  SELECT COUNT(*) INTO total_plays_count
  FROM public.game_sessions
  WHERE host_id = host_uuid
  AND status != 'lobby';

  -- 3. Total Unique Players across all sessions
  SELECT COUNT(DISTINCT user_id) INTO total_players_count
  FROM public.game_participants gp
  JOIN public.game_sessions gs ON gp.session_id = gs.id
  WHERE gs.host_id = host_uuid
  AND gp.user_id != host_uuid;

  -- 4. Average Rating across all quizzes owned by host
  SELECT COALESCE(AVG(qr.rating), 0) INTO average_rating
  FROM public.quiz_ratings qr
  JOIN public.quizzes q ON qr.quiz_id = q.id
  WHERE q.owner_id = host_uuid;

  result := json_build_object(
    'total_quizzes', total_quizzes_count,
    'total_plays', total_plays_count,
    'total_players', total_players_count,
    'avg_rating', ROUND(average_rating, 1)
  );

  RETURN result;
END;
$$;

-- RPC: Get Quiz Analytics Detailed
CREATE OR REPLACE FUNCTION get_quiz_analytics_detailed(quiz_uuid uuid)
RETURNS json
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  play_count integer;
  avg_score numeric;
  total_sessions integer;
  finished_sessions integer;
  comp_rate numeric;
  result json;
BEGIN
  -- 1. Play Count
  SELECT COUNT(*) INTO play_count
  FROM public.game_sessions
  WHERE quiz_id = quiz_uuid
  AND status != 'lobby';

  -- 2. Average Score
  SELECT COALESCE(AVG(score), 0) INTO avg_score
  FROM public.leaderboard
  WHERE quiz_id = quiz_uuid;

  -- 3. Completion Rate
  SELECT COUNT(*) INTO total_sessions
  FROM public.game_sessions
  WHERE quiz_id = quiz_uuid
  AND status != 'lobby';

  SELECT COUNT(*) INTO finished_sessions
  FROM public.game_sessions
  WHERE quiz_id = quiz_uuid
  AND status = 'completed';

  IF total_sessions > 0 THEN
    comp_rate := finished_sessions::numeric / total_sessions::numeric;
  ELSE
    comp_rate := 0;
  END IF;

  result := json_build_object(
    'quiz_id', quiz_uuid,
    'play_count', play_count,
    'avg_score', ROUND(avg_score, 1),
    'completion_rate', ROUND(comp_rate, 2)
  );

  RETURN result;
END;
$$;

-- RPC: Get Individual Quiz Performance for Host
CREATE OR REPLACE FUNCTION get_host_quizzes_performance(host_uuid uuid)
RETURNS json
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  result json;
BEGIN
  SELECT json_agg(q_stats) INTO result
  FROM (
    SELECT 
      q.id,
      q.title,
      q.category,
      COALESCE((
        SELECT COUNT(*) 
        FROM public.game_sessions gs 
        WHERE gs.quiz_id = q.id AND gs.status != 'lobby'
      ), 0) as play_count,
      COALESCE((
        SELECT ROUND(AVG(rating), 1) 
        FROM public.quiz_ratings qr 
        WHERE qr.quiz_id = q.id
      ), 0) as avg_rating
    FROM public.quizzes q
    WHERE q.owner_id = host_uuid
    ORDER BY q.created_at DESC
  ) q_stats;

  RETURN COALESCE(result, '[]'::json);
END;
$$;
