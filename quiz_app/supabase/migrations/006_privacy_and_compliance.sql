-- ==========================================
-- Migration: Privacy & Compliance (Phase 1)
-- Purpose: Support GDPR "Right to be Forgotten" and Security Auditing
-- ==========================================

-- 0. BOOTSTRAP INITIAL SCHEMA
CREATE TABLE IF NOT EXISTS public.profiles (id UUID PRIMARY KEY);
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS username TEXT UNIQUE;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS full_name TEXT;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS avatar_url TEXT;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS bio TEXT;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS role TEXT DEFAULT 'user';
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS total_points INTEGER DEFAULT 0;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS current_streak INTEGER DEFAULT 0;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS highest_streak INTEGER DEFAULT 0;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS created_at TIMESTAMPTZ DEFAULT now();
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT now();

CREATE TABLE IF NOT EXISTS public.quizzes (id UUID PRIMARY KEY DEFAULT gen_random_uuid());
ALTER TABLE public.quizzes ADD COLUMN IF NOT EXISTS owner_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE;
ALTER TABLE public.quizzes ADD COLUMN IF NOT EXISTS title TEXT;
ALTER TABLE public.quizzes ADD COLUMN IF NOT EXISTS description TEXT;
ALTER TABLE public.quizzes ADD COLUMN IF NOT EXISTS is_public BOOLEAN DEFAULT true;
ALTER TABLE public.quizzes ADD COLUMN IF NOT EXISTS category TEXT DEFAULT 'General';
ALTER TABLE public.quizzes ADD COLUMN IF NOT EXISTS play_count INTEGER DEFAULT 0;
ALTER TABLE public.quizzes ADD COLUMN IF NOT EXISTS created_at TIMESTAMPTZ DEFAULT now();
ALTER TABLE public.quizzes ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT now();

CREATE TABLE IF NOT EXISTS public.questions (id UUID PRIMARY KEY DEFAULT gen_random_uuid());
ALTER TABLE public.questions ADD COLUMN IF NOT EXISTS quiz_id UUID REFERENCES public.quizzes(id) ON DELETE CASCADE;
ALTER TABLE public.questions ADD COLUMN IF NOT EXISTS content TEXT;
ALTER TABLE public.questions ADD COLUMN IF NOT EXISTS options JSONB;
ALTER TABLE public.questions ADD COLUMN IF NOT EXISTS correct_index INTEGER;
ALTER TABLE public.questions ADD COLUMN IF NOT EXISTS order_index INTEGER;
ALTER TABLE public.questions ADD COLUMN IF NOT EXISTS timer_seconds INTEGER DEFAULT 20;

CREATE TABLE IF NOT EXISTS public.game_sessions (id UUID PRIMARY KEY DEFAULT gen_random_uuid());
ALTER TABLE public.game_sessions ADD COLUMN IF NOT EXISTS game_pin TEXT UNIQUE;
ALTER TABLE public.game_sessions ADD COLUMN IF NOT EXISTS quiz_id UUID REFERENCES public.quizzes(id) ON DELETE CASCADE;
ALTER TABLE public.game_sessions ADD COLUMN IF NOT EXISTS host_id UUID REFERENCES auth.users(id) ON DELETE SET NULL;
ALTER TABLE public.game_sessions ADD COLUMN IF NOT EXISTS status TEXT DEFAULT 'lobby';
ALTER TABLE public.game_sessions ADD COLUMN IF NOT EXISTS current_question_index INTEGER DEFAULT 0;
ALTER TABLE public.game_sessions ADD COLUMN IF NOT EXISTS is_team_mode BOOLEAN DEFAULT false;
ALTER TABLE public.game_sessions ADD COLUMN IF NOT EXISTS team_member_limit INTEGER DEFAULT 0;
ALTER TABLE public.game_sessions ADD COLUMN IF NOT EXISTS teams JSONB DEFAULT '{}';
ALTER TABLE public.game_sessions ADD COLUMN IF NOT EXISTS is_timer_accelerated BOOLEAN DEFAULT false;
ALTER TABLE public.game_sessions ADD COLUMN IF NOT EXISTS manual_advance BOOLEAN DEFAULT false;
ALTER TABLE public.game_sessions ADD COLUMN IF NOT EXISTS round_started_at TIMESTAMPTZ;
ALTER TABLE public.game_sessions ADD COLUMN IF NOT EXISTS round_ends_at TIMESTAMPTZ;
ALTER TABLE public.game_sessions ADD COLUMN IF NOT EXISTS created_at TIMESTAMPTZ DEFAULT now();
ALTER TABLE public.game_sessions ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT now();

CREATE TABLE IF NOT EXISTS public.game_participants (id UUID PRIMARY KEY DEFAULT gen_random_uuid());
ALTER TABLE public.game_participants ADD COLUMN IF NOT EXISTS session_id UUID REFERENCES public.game_sessions(id) ON DELETE CASCADE;
ALTER TABLE public.game_participants ADD COLUMN IF NOT EXISTS user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE;
ALTER TABLE public.game_participants ADD COLUMN IF NOT EXISTS nickname TEXT;
ALTER TABLE public.game_participants ADD COLUMN IF NOT EXISTS score INTEGER DEFAULT 0;
ALTER TABLE public.game_participants ADD COLUMN IF NOT EXISTS is_host BOOLEAN DEFAULT false;
ALTER TABLE public.game_participants ADD COLUMN IF NOT EXISTS joined_at TIMESTAMPTZ DEFAULT now();

CREATE TABLE IF NOT EXISTS public.game_answers (id UUID PRIMARY KEY DEFAULT gen_random_uuid());
ALTER TABLE public.game_answers ADD COLUMN IF NOT EXISTS session_id UUID REFERENCES public.game_sessions(id) ON DELETE CASCADE;
ALTER TABLE public.game_answers ADD COLUMN IF NOT EXISTS user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE;
ALTER TABLE public.game_answers ADD COLUMN IF NOT EXISTS question_index INTEGER;
ALTER TABLE public.game_answers ADD COLUMN IF NOT EXISTS is_correct BOOLEAN;
ALTER TABLE public.game_answers ADD COLUMN IF NOT EXISTS submitted_at TIMESTAMPTZ DEFAULT now();

CREATE TABLE IF NOT EXISTS public.challenges (id UUID PRIMARY KEY DEFAULT gen_random_uuid());
ALTER TABLE public.challenges ADD COLUMN IF NOT EXISTS quiz_id UUID REFERENCES public.quizzes(id) ON DELETE CASCADE;
ALTER TABLE public.challenges ADD COLUMN IF NOT EXISTS quiz_title TEXT;
ALTER TABLE public.challenges ADD COLUMN IF NOT EXISTS status TEXT DEFAULT 'pending';
ALTER TABLE public.challenges ADD COLUMN IF NOT EXISTS challenger_id UUID REFERENCES auth.users(id) ON DELETE CASCADE;
ALTER TABLE public.challenges ADD COLUMN IF NOT EXISTS challenger_username TEXT;
ALTER TABLE public.challenges ADD COLUMN IF NOT EXISTS challenger_score INTEGER DEFAULT 0;
ALTER TABLE public.challenges ADD COLUMN IF NOT EXISTS opponent_id UUID REFERENCES auth.users(id) ON DELETE CASCADE;
ALTER TABLE public.challenges ADD COLUMN IF NOT EXISTS opponent_username TEXT;
ALTER TABLE public.challenges ADD COLUMN IF NOT EXISTS opponent_score INTEGER DEFAULT 0;
ALTER TABLE public.challenges ADD COLUMN IF NOT EXISTS created_at TIMESTAMPTZ DEFAULT now();
ALTER TABLE public.challenges ADD COLUMN IF NOT EXISTS completed_at TIMESTAMPTZ;

CREATE TABLE IF NOT EXISTS public.leaderboard (
    quiz_id UUID REFERENCES public.quizzes(id) ON DELETE CASCADE,
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
    PRIMARY KEY (quiz_id, user_id)
);
ALTER TABLE public.leaderboard ADD COLUMN IF NOT EXISTS score INTEGER;
ALTER TABLE public.leaderboard ADD COLUMN IF NOT EXISTS team_name TEXT;
ALTER TABLE public.leaderboard ADD COLUMN IF NOT EXISTS members JSONB;
ALTER TABLE public.leaderboard ADD COLUMN IF NOT EXISTS created_at TIMESTAMPTZ DEFAULT now();

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.quizzes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.questions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.game_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.game_participants ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.game_answers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.challenges ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.leaderboard ENABLE ROW LEVEL SECURITY;

-- 1. Security Audit Logs
CREATE TABLE IF NOT EXISTS public.security_audit_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    event_type TEXT NOT NULL, 
    details JSONB,
    ip_address TEXT,
    created_at TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE public.security_audit_logs ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Admins can view audit logs" ON public.security_audit_logs;
CREATE POLICY "Admins can view audit logs" ON public.security_audit_logs
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM public.profiles 
            WHERE id = auth.uid() 
            AND role IN ('admin', 'dev')
        )
    );

DROP POLICY IF EXISTS "Users can insert their own audit logs" ON public.security_audit_logs;
CREATE POLICY "Users can insert their own audit logs" ON public.security_audit_logs
    FOR INSERT WITH CHECK (auth.uid() = user_id OR user_id IS NULL);

-- 2. Anonymization Function
CREATE OR REPLACE FUNCTION public.fn_anonymize_user(p_user_id UUID)
RETURNS VOID AS $$
BEGIN
    IF (auth.uid() != p_user_id AND NOT EXISTS (
        SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role IN ('admin', 'dev')
    )) THEN
        RAISE EXCEPTION 'Unauthorized';
    END IF;

    UPDATE public.profiles
    SET 
        full_name = 'Deleted User',
        username = 'user_' || substr(p_user_id::text, 1, 8),
        avatar_url = NULL,
        bio = NULL,
        total_points = 0
    WHERE id = p_user_id;

    UPDATE public.game_participants
    SET nickname = 'Player'
    WHERE user_id = p_user_id;

    INSERT INTO public.security_audit_logs (user_id, event_type, details)
    VALUES (p_user_id, 'ACCOUNT_ANONYMIZED', jsonb_build_object('timestamp', now()));

END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
