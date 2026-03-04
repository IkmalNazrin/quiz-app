-- Migration: Edge Function Rate Limiting
-- Adds a generic table and RPC to allow edge functions to perform persistent rate limiting.

CREATE TABLE IF NOT EXISTS edge_rate_limits (
    identifier text PRIMARY KEY,
    request_count integer NOT NULL DEFAULT 1,
    reset_at timestamptz NOT NULL
);

-- Note: We use an unlogged table if possible for performance, but Supabase standard is logged.
-- For pure rate limiting, durability isn't strictly necessary, but standard tables are fine for typical load.

CREATE OR REPLACE FUNCTION check_rate_limit(p_identifier text, p_max_requests int, p_window_seconds int)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_current_count int;
    v_reset_at timestamptz;
BEGIN
    -- Cleanup expired limits occasionally (can also be done via pg_cron, but we do it lazily here to save space)
    -- In high throughput, you'd offload cleanup to a cron job.
    
    INSERT INTO edge_rate_limits (identifier, request_count, reset_at)
    VALUES (p_identifier, 1, now() + (p_window_seconds || ' seconds')::interval)
    ON CONFLICT (identifier) DO UPDATE
    SET 
        request_count = CASE 
                            WHEN edge_rate_limits.reset_at < now() THEN 1 
                            ELSE edge_rate_limits.request_count + 1 
                        END,
        reset_at = CASE 
                       WHEN edge_rate_limits.reset_at < now() THEN now() + (p_window_seconds || ' seconds')::interval 
                       ELSE edge_rate_limits.reset_at 
                   END
    RETURNING request_count, reset_at INTO v_current_count, v_reset_at;

    IF v_current_count > p_max_requests THEN
        RETURN jsonb_build_object(
            'allowed', false,
            'retry_after', GREATEST(0, EXTRACT(EPOCH FROM (v_reset_at - now()))::int)
        );
    END IF;

    RETURN jsonb_build_object(
        'allowed', true,
        'retry_after', 0
    );
END;
$$;

-- Ensure service role has access
GRANT EXECUTE ON FUNCTION check_rate_limit(text, int, int) TO service_role;
