-- ==========================================
-- Migration: Organization Branding
-- ==========================================
ALTER TABLE public.organizations ADD COLUMN IF NOT EXISTS logo_url TEXT;
ALTER TABLE public.organizations ADD COLUMN IF NOT EXISTS theme_color TEXT;
