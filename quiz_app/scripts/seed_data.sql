-- ==========================================
-- SEED DATA SCRIPT: QuizApp Enterprise Beta (Hard Reset)
-- Purpose: Deduplicate quizzes and sync leaderboard data
-- Handles: Wiping fragmented sample data and inserting static records
-- Target Environment: Supabase SQL Editor
-- ==========================================

-- 0. SCHEMA UPDATES (Ensure category column exists)
ALTER TABLE public.quizzes ADD COLUMN IF NOT EXISTS category TEXT DEFAULT 'General';

-- Ensure leaderboard table has team support
ALTER TABLE public.leaderboard ADD COLUMN IF NOT EXISTS team_name TEXT;
ALTER TABLE public.leaderboard ADD COLUMN IF NOT EXISTS members JSONB;

-- Fix relationship for PostgREST joins (point to profiles instead of auth.users)
ALTER TABLE public.leaderboard DROP CONSTRAINT IF EXISTS leaderboard_user_id_fkey;
ALTER TABLE public.leaderboard ADD CONSTRAINT leaderboard_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id) ON DELETE CASCADE;

ALTER TABLE public.quizzes DROP CONSTRAINT IF EXISTS quizzes_owner_id_fkey;
ALTER TABLE public.quizzes ADD CONSTRAINT quizzes_owner_id_fkey FOREIGN KEY (owner_id) REFERENCES public.profiles(id) ON DELETE CASCADE;

DO $$
DECLARE
    -- Static User IDs (Derived from dump for 100% alignment)
    user_alice_id UUID   := '0c36fbdd-3f0a-4709-8d99-d7a557398830';
    user_bob_id UUID     := 'd9def948-6b7c-4728-a4f4-8f99a58857d2';
    user_charlie_id UUID := 'c8f6fde1-9894-44d5-8658-db8258e791d1';
    user_diana_id UUID   := 'ca24876f-2e11-41bd-b12b-6791c99f97c2';
    user_ethan_id UUID   := '0e168d64-e401-4970-a8bc-736ff29805b2';
    user_fiona_id UUID   := 'dfb24d40-937f-4721-a789-2d756d27e88b';
    user_george_id UUID  := 'd3aea73f-c769-47ce-9ffb-bc4fe1db6a46';
    user_hannah_id UUID  := 'feb3c070-e60b-47ce-8794-89bfc2eb4e6e';
    user_ian_id UUID     := '7083c4c8-3655-4efc-b9b7-4be2a1f1578d';
    user_jenny_id UUID   := 'acef24a7-7285-4c23-9e79-3091e22fb042';
    
    -- Main Host Account ID
    host_user_id UUID    := '8689c044-4894-4bfe-a552-704aa85c93d8';
    
    -- Quiz IDs (Fixed for consistency)
    quiz_tech_id UUID    := '11111111-1111-1111-1111-111111111111';
    quiz_history_id UUID := '22222222-2222-2222-2222-222222222222';
    quiz_science_id UUID := '33333333-3333-3333-3333-333333333333';
    
    -- Ikmal's Specific Quizzes
    quiz_math_id UUID    := 'b7a9a69d-c0de-4a06-a300-d17e28e7fd29';
    quiz_flutter_id UUID := '88e5a62c-3884-48ac-aade-5b1f2299d81f';
    quiz_space_id UUID   := '7040f599-3546-439e-b088-64418cafd359';
    
BEGIN
    -- 1. HARD RESET: Wipe all variations of sample quizzes to prevent fragmentation
    DELETE FROM public.leaderboard WHERE quiz_id IN (SELECT id FROM public.quizzes WHERE title IN ('Modern Tech Trivia', 'Ancient Civilizations', 'Cosmic Wonders', 'Quick Math', 'Flutter Advanced Patterns', 'Space Odyssey'));
    DELETE FROM public.questions WHERE quiz_id IN (SELECT id FROM public.quizzes WHERE title IN ('Modern Tech Trivia', 'Ancient Civilizations', 'Cosmic Wonders', 'Quick Math', 'Flutter Advanced Patterns', 'Space Odyssey'));
    DELETE FROM public.challenges WHERE quiz_id IN (SELECT id FROM public.quizzes WHERE title IN ('Modern Tech Trivia', 'Ancient Civilizations', 'Cosmic Wonders', 'Quick Math', 'Flutter Advanced Patterns', 'Space Odyssey'));
    DELETE FROM public.quizzes WHERE title IN ('Modern Tech Trivia', 'Ancient Civilizations', 'Cosmic Wonders', 'Quick Math', 'Flutter Advanced Patterns', 'Space Odyssey');

    -- 2. ROBUST USER CREATION
    INSERT INTO auth.users (id, email, raw_user_meta_data, created_at)
    VALUES 
        (user_alice_id, 'alice@test.com', '{"full_name": "Alice Wonderland"}', now()),
        (user_bob_id, 'bob@test.com', '{"full_name": "Bob Builder"}', now()),
        (user_charlie_id, 'charlie@test.com', '{"full_name": "Charlie Brown"}', now()),
        (user_diana_id, 'diana@test.com', '{"full_name": "Diana Ross"}', now()),
        (user_ethan_id, 'ethan@test.com', '{"full_name": "Ethan Hunt"}', now()),
        (user_fiona_id, 'fiona@test.com', '{"full_name": "Fiona Apple"}', now()),
        (user_george_id, 'george@test.com', '{"full_name": "George Lucas"}', now()),
        (user_hannah_id, 'hannah@test.com', '{"full_name": "Hannah Montana"}', now()),
        (user_ian_id, 'ian@test.com', '{"full_name": "Ian Fleming"}', now()),
        (user_jenny_id, 'jenny@test.com', '{"full_name": "Jenny Forest"}', now())
    ON CONFLICT (id) DO NOTHING;

    -- 3. SYNC PROFILES
    INSERT INTO public.profiles (id, username, full_name, avatar_url, bio, total_points, current_streak, highest_streak)
    VALUES 
        (user_alice_id, 'AliceAce', 'Alice Wonderland', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Alice', 'Master of riddles and wonders. 🍄', 12500, 15, 20),
        (user_bob_id, 'BobThePro', 'Bob Builder', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Bob', 'Can we build it? Yes we can! 🏗️', 8900, 5, 12),
        (user_charlie_id, 'CharlieWiz', 'Charlie Brown', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Charlie', 'Always aiming for that home run. ⚾', 15200, 22, 22),
        (user_diana_id, 'DianaDash', 'Diana Ross', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Diana', 'The lead singer of your favorite trivia. 🎤', 6700, 3, 8),
        (user_ethan_id, 'EthanEdge', 'Ethan Hunt', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Ethan', 'Your mission, should you choose to accept it... 🕵️‍♂️', 11000, 0, 15),
        (user_fiona_id, 'FionaFierce', 'Fiona Apple', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Fiona', 'Extraordinary machine in a trivia world. 🍎', 9200, 8, 10),
        (user_george_id, 'GeoGenius', 'George Lucas', 'https://api.dicebear.com/7.x/avataaars/svg?seed=George', 'In a galaxy far, far away... I am the best. 🌌', 13400, 12, 18),
        (user_hannah_id, 'HannahHero', 'Hannah Montana', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Hannah', 'The best of both worlds: Pop & Trivia. 🎸', 7800, 4, 9),
        (user_ian_id, 'IanInvincible', 'Ian Fleming', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Ian', 'Shaken, not stirred. Trivia is forever. 🍸', 10500, 6, 14),
        (user_jenny_id, 'JennyJoy', 'Jenny Forest', 'https://api.dicebear.com/7.x/avataaars/svg?seed=Jenny', 'Life is like a box of trivia! 🍫', 5400, 2, 5)
    ON CONFLICT (id) DO UPDATE SET
        username = EXCLUDED.username,
        full_name = EXCLUDED.full_name,
        bio = EXCLUDED.bio,
        total_points = EXCLUDED.total_points,
        current_streak = EXCLUDED.current_streak,
        highest_streak = EXCLUDED.highest_streak;

    -- 4. INSERT CLEAN QUIZZES
    INSERT INTO public.quizzes (id, owner_id, title, description, is_public, play_count, category)
    VALUES 
        (quiz_tech_id, user_alice_id, 'Modern Tech Trivia', 'Test your knowledge on AI, Quantum Computing, and Next.js', true, 142, 'Tech'),
        (quiz_history_id, user_bob_id, 'Ancient Civilizations', 'Explore the mysteries of Egypt, Rome, and the Maya.', true, 89, 'History'),
        (quiz_science_id, user_charlie_id, 'Cosmic Wonders', 'A deep dive into Astrophysics and Space Exploration.', true, 205, 'Science'),
        -- Host (Ikmal) Quizzes
        (quiz_math_id, host_user_id, 'Quick Math', '10 rapid fire arithmetic questions for all ages.', true, 156, 'Education'),
        (quiz_flutter_id, host_user_id, 'Flutter Advanced Patterns', 'Deep dive into Riverpod and Performance.', true, 42, 'Programming'),
        (quiz_space_id, host_user_id, 'Space Odyssey', 'Draft quiz about the solar system.', false, 12, 'Science');

    -- 5. INSERT QUESTIONS (Prevent '0 Qs' issue)
    INSERT INTO public.questions (quiz_id, content, options, correct_index, order_index)
    VALUES 
        (quiz_tech_id, 'What does GPT stand for?', '["Generative Pre-trained Transformer", "General Purpose Tool", "Global Positioning Tracker", "Grid Processing Technology"]', 0, 1),
        (quiz_tech_id, 'Which language is used for Flutter?', '["Java", "Swift", "Dart", "C++"]', 2, 2),
        (quiz_history_id, 'Who was the first emperor of Rome?', '["Julius Caesar", "Augustus", "Nero", "Caligula"]', 1, 1),
        (quiz_science_id, 'Which planet is known as the Red Planet?', '["Venus", "Mars", "Jupiter", "Saturn"]', 1, 1);

    -- 6. POPULATE LEADERBOARD (Dump sync)
    INSERT INTO public.leaderboard (quiz_id, user_id, score, team_name, members)
    VALUES
        -- Cosmic Wonders (Science)
        (quiz_science_id, user_alice_id, 990, null, null),
        (quiz_science_id, user_ian_id, 940, null, null),
        (quiz_science_id, user_charlie_id, 920, null, null),
        (quiz_science_id, user_george_id, 880, null, null),
        (quiz_science_id, user_fiona_id, 850, null, null),
        (quiz_science_id, user_hannah_id, 820, null, null),
        (quiz_science_id, user_ethan_id, 790, null, null),
        (quiz_science_id, user_ian_id, 3500, 'Galaxy Gang', jsonb_build_array(
           jsonb_build_object('id', user_ian_id, 'name', 'IanInvincible'),
           jsonb_build_object('id', user_charlie_id, 'name', 'CharlieWiz'),
           jsonb_build_object('id', user_alice_id, 'name', 'AliceAce')
        )),
        (quiz_science_id, user_george_id, 3100, 'Supernovae', jsonb_build_array(
           jsonb_build_object('id', user_george_id, 'name', 'GeoGenius'),
           jsonb_build_object('id', user_ethan_id, 'name', 'EthanEdge'),
           jsonb_build_object('id', user_fiona_id, 'name', 'FionaFierce')
        )),
        
        -- Modern Tech Trivia (Tech)
        (quiz_tech_id, user_charlie_id, 980, null, null),
        (quiz_tech_id, user_george_id, 960, null, null),
        (quiz_tech_id, user_alice_id, 920, null, null),
        (quiz_tech_id, user_ian_id, 880, null, null),
        (quiz_tech_id, user_ethan_id, 850, null, null),
        (quiz_tech_id, user_alice_id, 3200, 'Cyber Kings', jsonb_build_array(
           jsonb_build_object('id', user_alice_id, 'name', 'AliceAce'),
           jsonb_build_object('id', user_bob_id, 'name', 'BobThePro'),
           jsonb_build_object('id', user_george_id, 'name', 'GeoGenius')
        )),
        (quiz_tech_id, user_charlie_id, 2950, 'Neural Knights', jsonb_build_array(
           jsonb_build_object('id', user_charlie_id, 'name', 'CharlieWiz'),
           jsonb_build_object('id', user_diana_id, 'name', 'DianaDash'),
           jsonb_build_object('id', user_ian_id, 'name', 'IanInvincible')
        )),
        
        -- Ancient Civilizations (History)
        (quiz_history_id, user_bob_id, 1000, null, null),
        (quiz_history_id, user_alice_id, 950, null, null),
        (quiz_history_id, user_charlie_id, 910, null, null),
        (quiz_history_id, user_ian_id, 800, null, null),
        
        -- Quick Math (Ikmal's) Leaderboard
        (quiz_math_id, user_alice_id, 1200, null, null),
        (quiz_math_id, user_bob_id, 1150, null, null),
        (quiz_math_id, user_charlie_id, 1300, null, null),
        
        -- Flutter Advanced (Ikmal's) Leaderboard
        (quiz_flutter_id, user_ian_id, 950, null, null),
        (quiz_flutter_id, user_george_id, 880, null, null);

    -- 7. RICH CHALLENGE HISTORY (Arena/Social Tab)
    -- Using the main test account as a hub for challenges
    BEGIN
        -- Clear existing challenges to ensure clean test state
        DELETE FROM public.challenges;

        INSERT INTO public.challenges (quiz_id, quiz_title, status, challenger_id, challenger_username, challenger_score, opponent_id, opponent_username, opponent_score, created_at, completed_at)
        VALUES 
            -- Pending challenges (The user needs to accept these)
            (quiz_tech_id, 'Modern Tech Trivia', 'pending', user_alice_id, 'AliceAce', 950, host_user_id, 'Ikmal Nazrin', 0, now() - interval '2 hours', null),
            (quiz_science_id, 'Cosmic Wonders', 'pending', user_charlie_id, 'CharlieWiz', 920, host_user_id, 'Ikmal Nazrin', 0, now() - interval '5 hours', null),
            (quiz_history_id, 'Ancient Civilizations', 'pending', user_bob_id, 'BobThePro', 880, host_user_id, 'Ikmal Nazrin', 0, now() - interval '1 day', null),
            
            -- Completed challenges (History) - Recent wins
            (quiz_tech_id, 'Modern Tech Trivia', 'completed', host_user_id, 'Ikmal Nazrin', 1050, user_diana_id, 'DianaDash', 920, now() - interval '1 day', now() - interval '23 hours'),
            (quiz_science_id, 'Cosmic Wonders', 'completed', host_user_id, 'Ikmal Nazrin', 1100, user_ethan_id, 'EthanEdge', 850, now() - interval '2 days', now() - interval '47 hours'),
            
            -- Team Challenge History
            (quiz_tech_id, 'Modern Tech Trivia', 'completed', host_user_id, 'Cyber Kings', 3200, user_charlie_id, 'Neural Knights', 2950, now() - interval '12 hours', now() - interval '11 hours'),

            -- Completed challenges (History) - Losses
            (quiz_history_id, 'Ancient Civilizations', 'completed', user_george_id, 'GeoGenius', 1200, host_user_id, 'Ikmal Nazrin', 950, now() - interval '3 days', now() - interval '71 hours'),
            (quiz_tech_id, 'Modern Tech Trivia', 'completed', user_hannah_id, 'HannahHero', 980, host_user_id, 'Ikmal Nazrin', 920, now() - interval '4 days', now() - interval '95 hours'),
            
            -- Additional Pending to test scrolling
            (quiz_science_id, 'Cosmic Wonders', 'pending', user_fiona_id, 'FionaFierce', 850, host_user_id, 'Ikmal Nazrin', 0, now() - interval '1 hour', null),
            (quiz_tech_id, 'Modern Tech Trivia', 'pending', user_jenny_id, 'JennyJoy', 700, host_user_id, 'Ikmal Nazrin', 0, now() - interval '30 minutes', null),

            -- Other users challenging each other
            (quiz_science_id, 'Cosmic Wonders', 'completed', user_charlie_id, 'CharlieWiz', 950, user_alice_id, 'AliceAce', 880, now() - interval '1 day', now() - interval '23 hours'),
            (quiz_history_id, 'Ancient Civilizations', 'completed', user_ian_id, 'IanInvincible', 1050, user_jenny_id, 'JennyJoy', 700, now() - interval '5 days', now() - interval '119 hours');
    END;

    -- 8. ENRICHED LEADERBOARD DATA (Browse Page Previews)
    -- Science Leaderboard Enrichment
    INSERT INTO public.leaderboard (quiz_id, user_id, score) 
    VALUES 
        (quiz_science_id, user_diana_id, 810),
        (quiz_science_id, user_bob_id, 750),
        (quiz_science_id, user_jenny_id, 680);

    -- Tech Leaderboard Enrichment
    INSERT INTO public.leaderboard (quiz_id, user_id, score)
    VALUES
        (quiz_tech_id, user_bob_id, 820),
        (quiz_tech_id, user_fiona_id, 790),
        (quiz_tech_id, user_hannah_id, 740),
        (quiz_tech_id, user_jenny_id, 650);

    -- History Leaderboard Enrichment
    INSERT INTO public.leaderboard (quiz_id, user_id, score, team_name, members)
    VALUES
        (quiz_history_id, user_ethan_id, 890, null, null),
        (quiz_history_id, user_fiona_id, 820, null, null),
        (quiz_history_id, user_george_id, 760, null, null),
        (quiz_history_id, user_hannah_id, 690, null, null),
        (quiz_history_id, user_alice_id, 2800, 'Egyptian Empire', jsonb_build_array(
            jsonb_build_object('id', user_alice_id, 'name', 'AliceAce'),
            jsonb_build_object('id', user_bob_id, 'name', 'BobThePro')
        )),
        (quiz_history_id, user_charlie_id, 2650, 'Roman Legion', jsonb_build_array(
            jsonb_build_object('id', user_charlie_id, 'name', 'CharlieWiz'),
            jsonb_build_object('id', user_diana_id, 'name', 'DianaDash')
        ));

    -- 9. GAME SESSIONS & PARTICIPANTS (Are@na testing)
    INSERT INTO public.game_sessions (id, game_pin, quiz_id, host_id, status, current_question_index, is_team_mode, team_member_limit, teams, created_at)
    VALUES 
        ('43bd50f6-2382-4432-8648-ef36305707c0', '463359', quiz_tech_id, host_user_id, 'lobby', 0, false, 0, '{}', now()),
        ('54263a9a-cb59-42ec-b552-2f91c835d9d7', '953793', quiz_tech_id, host_user_id, 'lobby', 0, false, 0, '{}', now()),
        ('90d4fa4e-7e35-45f3-ad5d-922079c9431f', '241927', quiz_tech_id, host_user_id, 'lobby', 0, false, 0, '{}', now());

    INSERT INTO public.game_participants (id, session_id, user_id, nickname, score, joined_at, is_host)
    VALUES 
        ('797ac223-2233-43c7-ae43-aab6ccd32c75', '90d4fa4e-7e35-45f3-ad5d-922079c9431f', host_user_id, 'Host', 0, now(), true),
        ('b7972357-221e-4d8d-ac05-0203f78d8c73', '54263a9a-cb59-42ec-b552-2f91c835d9d7', host_user_id, 'Host', 0, now(), true),
        ('f846988c-892b-43a1-a99e-1541646291e2', '43bd50f6-2382-4432-8648-ef36305707c0', host_user_id, 'Host', 0, now(), true);

    -- 10. SAMPLE RATINGS (For Analytics Verification)
    INSERT INTO public.quiz_ratings (quiz_id, user_id, rating)
    VALUES 
        (quiz_tech_id, user_alice_id, 5),
        (quiz_tech_id, user_bob_id, 4),
        (quiz_science_id, user_charlie_id, 5),
        (quiz_science_id, user_fiona_id, 4),
        -- Ratings for Ikmal's Quizzes
        (quiz_math_id, user_alice_id, 5),
        (quiz_math_id, user_bob_id, 5),
        (quiz_flutter_id, user_ian_id, 4);

    -- 11. EXTRA GAME SESSIONS FOR IKMAL
    INSERT INTO public.game_sessions (id, game_pin, quiz_id, host_id, status, created_at)
    VALUES 
        (gen_random_uuid(), '123456', quiz_math_id, host_user_id, 'completed', now() - interval '1 day'),
        (gen_random_uuid(), '654321', quiz_flutter_id, host_user_id, 'completed', now() - interval '2 days');

    -- Ensure those specific sessions are marked as 'completed' for filtering verification
    UPDATE public.game_sessions SET status = 'completed' WHERE id IN ('43bd50f6-2382-4432-8648-ef36305707c0', '54263a9a-cb59-42ec-b552-2f91c835d9d7');
    -- Update one session to point to Ikmal's quiz
    UPDATE public.game_sessions SET quiz_id = quiz_math_id WHERE id = '43bd50f6-2382-4432-8648-ef36305707c0';
    -- Update one session to point to a different quiz for variety
    UPDATE public.game_sessions SET quiz_id = quiz_science_id WHERE id = '54263a9a-cb59-42ec-b552-2f91c835d9d7';

END $$;

-- 8. SECURITY: Ensure public tables are readable (Fix for empty results issue)
ALTER TABLE public.quizzes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.questions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.leaderboard ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Public Quizzes are readable" ON public.quizzes;
CREATE POLICY "Public Quizzes are readable" ON public.quizzes FOR SELECT USING (true);

DROP POLICY IF EXISTS "Questions are readable" ON public.questions;
CREATE POLICY "Questions are readable" ON public.questions FOR SELECT USING (true);

DROP POLICY IF EXISTS "Leaderboard is readable" ON public.leaderboard;
CREATE POLICY "Leaderboard is readable" ON public.leaderboard FOR SELECT USING (true);
