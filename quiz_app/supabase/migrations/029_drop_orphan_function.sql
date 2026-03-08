-- ==========================================
-- Migration: 029_drop_orphan_function
-- Purpose: Remove fn_process_data_deletion_requests which references
--          a non-existent data_deletion_requests table.
--          Data lifecycle is already handled by fn_anonymize_stale_data (migration 023).
-- ==========================================

DROP FUNCTION IF EXISTS public.fn_process_data_deletion_requests();
