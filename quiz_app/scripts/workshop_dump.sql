-- ==========================================
-- WORKSHOP DUMP DATA: Testing Suite
-- Target User: Ikmal Nazrin (8689c044-4894-4bfe-a552-704aa85c93d8)
-- Purpose: Populates the "Workshop" tab with diverse quiz data
-- ==========================================

DO $$
DECLARE
    host_user_id UUID := '8689c044-4894-4bfe-a552-704aa85c93d8';
    
    quiz_flutter_id UUID := gen_random_uuid();
    quiz_space_id UUID   := gen_random_uuid();
    quiz_math_id UUID    := gen_random_uuid();
BEGIN
    -- 1. CLEANUP: Optional - Remove previous test workshop data if needed
    -- DELETE FROM public.quizzes WHERE owner_id = host_user_id AND title IN ('Flutter Advanced Patterns', 'Space Odyssey', 'Quick Math');

    -- 2. INSERT QUIZZES
    INSERT INTO public.quizzes (id, owner_id, title, description, is_public, category, play_count)
    VALUES 
        (quiz_flutter_id, host_user_id, 'Flutter Advanced Patterns', 'Deep dive into Riverpod, CustomPainters, and Performance.', true, 'Programming', 42),
        (quiz_space_id, host_user_id, 'Space Odyssey', 'Draft quiz about the solar system and beyond.', false, 'Science', 0),
        (quiz_math_id, host_user_id, 'Quick Math', '10 rapid fire arithmetic questions for all ages.', true, 'Education', 156);

    -- 3. INSERT QUESTIONS
    
    -- Flutter Questions
    INSERT INTO public.questions (quiz_id, content, options, correct_index, order_index, timer_seconds)
    VALUES 
        (quiz_flutter_id, 'Which Riverpod provider is best for async data that can change?', '["Provider", "FutureProvider", "StreamProvider", "AsyncNotifierProvider"]', 3, 1, 15),
        (quiz_flutter_id, 'What is the purpose of RepaintBoundary?', '["To group widgets", "To limit repainting to a specific subtree", "To handle gestures", "To provide layout constraints"]', 1, 2, 20),
        (quiz_flutter_id, 'How do you perform an expensive calculation without blocking the UI?', '["Future.delayed", "setState", "Isolates", "async/await"]', 2, 3, 15);

    -- Space Questions
    INSERT INTO public.questions (quiz_id, content, options, correct_index, order_index, timer_seconds)
    VALUES 
        (quiz_space_id, 'What is the largest moon of Saturn?', '["Titan", "Europa", "Ganymede", "Io"]', 0, 1, 10),
        (quiz_space_id, 'Which galaxy is the Milky Way expected to collide with?', '["Andromeda", "Sombrero", "Triangulum", "Centaurus A"]', 0, 2, 10);

    -- Math Questions
    INSERT INTO public.questions (quiz_id, content, options, correct_index, order_index, timer_seconds)
    VALUES 
        (quiz_math_id, 'What is 15 * 6?', '["80", "90", "100", "75"]', 1, 1, 5),
        (quiz_math_id, 'Square root of 144?', '["10", "11", "12", "13"]', 2, 2, 5),
        (quiz_math_id, 'What is 7 + 8 * 2?', '["30", "23", "17", "21"]', 1, 3, 5);

END $$;
