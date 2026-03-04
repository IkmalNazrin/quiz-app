-- Supabase Realtime Gameplay Schema (Idempotent Version)

-- Clean up existing tables if they exist to ensure a fresh migration
DROP TABLE IF EXISTS public.game_participants CASCADE;
DROP TABLE IF EXISTS public.game_sessions CASCADE;

-- 1. Game Sessions (The main room/lobby)
CREATE TABLE public.game_sessions (
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    game_pin text NOT NULL UNIQUE,
    quiz_id uuid REFERENCES public.quizzes(id) ON DELETE CASCADE,
    host_id uuid REFERENCES auth.users(id),
    status text NOT NULL DEFAULT 'lobby', -- lobby, playing, finished
    current_question_index integer DEFAULT 0,
    is_team_mode boolean DEFAULT false,
    team_member_limit integer DEFAULT 0,
    teams jsonb DEFAULT '{}'::jsonb,
    created_at timestamp with time zone DEFAULT now(),
    CONSTRAINT game_sessions_pkey PRIMARY KEY (id)
);

-- 2. Game Participants (Real-time score tracking)
CREATE TABLE public.game_participants (
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    session_id uuid REFERENCES public.game_sessions(id) ON DELETE CASCADE,
    user_id uuid REFERENCES auth.users(id), -- Null for anonymous guests
    nickname text NOT NULL,
    score integer DEFAULT 0,
    joined_at timestamp with time zone DEFAULT now(),
    is_host boolean DEFAULT false,
    team_name text,
    CONSTRAINT game_participants_pkey PRIMARY KEY (id)
);

-- Enable Realtime for these tables
-- We check if publication exists or handle it gracefully
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_publication WHERE pubname = 'supabase_realtime') THEN
        CREATE PUBLICATION supabase_realtime;
    END IF;
    ALTER PUBLICATION supabase_realtime ADD TABLE public.game_sessions;
    ALTER PUBLICATION supabase_realtime ADD TABLE public.game_participants;
EXCEPTION
    WHEN duplicate_object THEN 
        RAISE NOTICE 'Publication table already exists';
END $$;

-- RLS Policies
ALTER TABLE public.game_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.game_participants ENABLE ROW LEVEL SECURITY;

-- Drop existing policies to avoid conflicts
DROP POLICY IF EXISTS "Sessions are readable by everyone" ON public.game_sessions;
DROP POLICY IF EXISTS "Users can create sessions" ON public.game_sessions;
DROP POLICY IF EXISTS "Hosts can update sessions" ON public.game_sessions;
DROP POLICY IF EXISTS "Participants are readable by session members" ON public.game_participants;
DROP POLICY IF EXISTS "Anyone can join a session" ON public.game_participants;
DROP POLICY IF EXISTS "Participants can update their own data" ON public.game_participants;

-- Re-create Policies
-- Allow anyone to read sessions (to join by PIN)
CREATE POLICY "Sessions are readable by everyone" ON public.game_sessions
    FOR SELECT USING (true);

-- Only authenticated users can create sessions
CREATE POLICY "Users can create sessions" ON public.game_sessions
    FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);

-- Only the host can update the session (start game, next question)
CREATE POLICY "Hosts can update sessions" ON public.game_sessions
    FOR UPDATE USING (auth.uid() = host_id);

-- Participants logic
CREATE POLICY "Participants are readable by session members" ON public.game_participants
    FOR SELECT USING (true);

CREATE POLICY "Anyone can join a session" ON public.game_participants
    FOR INSERT WITH CHECK (true);

-- Users can only update their own scores
CREATE POLICY "Participants can update their own data" ON public.game_participants
    FOR UPDATE USING (user_id = auth.uid() OR (user_id IS NULL)); -- Simple policy for demo/guests

-- Data Lifecycle Automated Scrubbing
CREATE EXTENSION IF NOT EXISTS pg_cron WITH SCHEMA pg_catalog;

CREATE OR REPLACE FUNCTION fn_anonymize_stale_data() RETURNS void AS $$
BEGIN
    UPDATE game_participants gp
    SET nickname = 'Anonymized Player-' || substr(gp.id::text, 1, 8)
    FROM game_sessions gs
    WHERE gp.session_id = gs.id
    AND gs.status IN ('round_over', 'finished', 'cancelled', 'banned')
    AND gs.created_at < NOW() - INTERVAL '30 days'
    AND gp.nickname NOT LIKE 'Anonymized Player-%';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION fn_delete_inactive_guests() RETURNS void AS $$
BEGIN
    DELETE FROM auth.users
    WHERE is_anonymous = true
    AND (last_sign_in_at < NOW() - INTERVAL '90 days' OR (last_sign_in_at IS NULL AND created_at < NOW() - INTERVAL '90 days'));
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

SELECT cron.schedule('anonymize_stale_participants_nightly', '0 3 * * *', 'SELECT fn_anonymize_stale_data();');
SELECT cron.schedule('purge_inactive_guests_nightly', '0 3 * * *', 'SELECT fn_delete_inactive_guests();');
