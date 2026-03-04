-- ==========================================
-- Migration: Organization SSO
-- ==========================================
ALTER TABLE public.organizations ADD COLUMN IF NOT EXISTS sso_settings JSONB;
