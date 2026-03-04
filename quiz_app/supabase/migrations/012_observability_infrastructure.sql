-- ==========================================
-- Migration: Observability Infrastructure
-- ==========================================

-- 1. App Logs Table
CREATE TABLE IF NOT EXISTS public.app_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    level TEXT NOT NULL, 
    category TEXT NOT NULL, 
    message TEXT NOT NULL,
    details JSONB,
    created_at TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE public.app_logs ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can insert own logs" ON public.app_logs
    FOR INSERT WITH CHECK (auth.uid() = user_id OR user_id IS NULL);

CREATE POLICY "Admins can view all logs" ON public.app_logs
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM public.profiles 
            WHERE id = auth.uid() 
            AND role IN ('admin', 'dev')
        )
    );

-- 2. Server Errors Table
CREATE TABLE IF NOT EXISTS public.server_errors (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    error_message TEXT NOT NULL,
    stack_trace TEXT,
    context TEXT, 
    metadata JSONB,
    created_at TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE public.server_errors ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can insert own errors" ON public.server_errors
    FOR INSERT WITH CHECK (auth.uid() = user_id OR user_id IS NULL);
CREATE POLICY "Admins can view errors" ON public.server_errors
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role IN ('admin', 'dev')
        )
    );

-- 3. App Performance Table
CREATE TABLE IF NOT EXISTS public.app_performance (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    trace_name TEXT NOT NULL,
    duration_ms INT NOT NULL,
    metadata JSONB,
    created_at TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE public.app_performance ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can insert own performance data" ON public.app_performance
    FOR INSERT WITH CHECK (auth.uid() = user_id OR user_id IS NULL);

-- 4. Function for Cleanup (referenced in 014)
CREATE OR REPLACE FUNCTION public.fn_cleanup_observability_data()
RETURNS void AS $$
BEGIN
    DELETE FROM public.app_logs WHERE created_at < now() - interval '14 days';
    DELETE FROM public.server_errors WHERE created_at < now() - interval '14 days';
    DELETE FROM public.app_performance WHERE created_at < now() - interval '14 days';
    
    INSERT INTO public.security_audit_logs (event_type, details)
    VALUES ('OBSERVABILITY_CLEANUP', jsonb_build_object('timestamp', now(), 'retention', '14 days'));
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
