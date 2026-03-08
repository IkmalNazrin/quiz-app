-- ==========================================
-- Migration: 028_fix_lint_errors
-- Purpose: Fix two issues found by `supabase db lint --linked`
--   1. fn_process_data_deletion_requests: text→interval type cast
--   2. delete_user_account: references non-existent public.users (should be public.profiles)
-- ==========================================

-- Fix 1: Recreate fn_process_data_deletion_requests with proper type cast
-- This function was created directly on remote and has a v_retention_period
-- variable that receives a text value without casting to interval.
CREATE OR REPLACE FUNCTION public.fn_process_data_deletion_requests()
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_user_id UUID;
    v_retention_period INTERVAL := '30 days'::INTERVAL;  -- explicit cast from text to interval
    v_request RECORD;
BEGIN
    -- Process any pending deletion requests older than retention period
    FOR v_request IN
        SELECT user_id, requested_at
        FROM public.data_deletion_requests
        WHERE status = 'pending'
        AND requested_at < NOW() - v_retention_period
    LOOP
        v_user_id := v_request.user_id;

        -- Anonymize profile data
        UPDATE public.profiles
        SET 
            full_name = 'Deleted Account',
            username = 'deleted_' || substr(v_user_id::text, 1, 8),
            avatar_url = NULL,
            bio = NULL,
            updated_at = NOW()
        WHERE id = v_user_id;

        -- Mark the request as processed
        UPDATE public.data_deletion_requests
        SET status = 'completed', processed_at = NOW()
        WHERE user_id = v_user_id AND status = 'pending';

        -- Delete from auth
        DELETE FROM auth.users WHERE id = v_user_id;
    END LOOP;
END;
$$;

-- Fix 2: Recreate delete_user_account to reference public.profiles (not public.users)
CREATE OR REPLACE FUNCTION public.delete_user_account()
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_user_id UUID;
BEGIN
    v_user_id := auth.uid();
    
    IF v_user_id IS NULL THEN
        RAISE EXCEPTION 'Not authenticated';
    END IF;

    -- Anonymize public profile data (PII Scrubbing)
    UPDATE public.profiles
    SET 
        full_name = 'Deleted Account',
        username = 'deleted_' || substr(v_user_id::text, 1, 8),
        avatar_url = NULL,
        bio = NULL,
        updated_at = NOW()
    WHERE id = v_user_id;

    -- Delete from Auth Users
    DELETE FROM auth.users WHERE id = v_user_id;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Account deletion failed: %', sqlerrm;
END;
$$;
