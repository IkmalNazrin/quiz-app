-- ==========================================
-- Migration: Health Check
-- Purpose: Operational status monitoring
-- ==========================================
CREATE OR REPLACE FUNCTION public.fn_health_check()
RETURNS jsonb AS $$
BEGIN
    RETURN jsonb_build_object('status', 'ok', 'timestamp', now());
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
