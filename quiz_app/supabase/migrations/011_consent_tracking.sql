-- ==========================================
-- Migration: Consent Tracking
-- ==========================================
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS consent_version TEXT DEFAULT '1.0.0';
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS consent_accepted_at TIMESTAMPTZ DEFAULT now();
