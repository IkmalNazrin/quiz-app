-- Migration for Automated Data Lifecycle Anonymization

-- 1. Enable pg_cron (if not already enabled)
CREATE EXTENSION IF NOT EXISTS pg_cron WITH SCHEMA pg_catalog;

-- 2. Function: Anonymize Stale Player Data (30+ Days)
-- Removes explicitly identifiable nicknames from historic sessions
CREATE OR REPLACE FUNCTION fn_anonymize_stale_data()
RETURNS void AS $$
BEGIN
    UPDATE game_participants gp
    SET nickname = 'Anonymized Player-' || substr(gp.id::text, 1, 8)
    FROM game_sessions gs
    WHERE gp.session_id = gs.id
    AND gs.status IN ('round_over', 'finished', 'cancelled', 'banned')
    AND gs.created_at < NOW() - INTERVAL '30 days'
    AND gp.nickname NOT LIKE 'Anonymized Player-%';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 3. Function: Purge Inactive Guest Accounts (90+ Days)
-- Cleans up auth records for completely anonymous users that never returned
CREATE OR REPLACE FUNCTION fn_delete_inactive_guests()
RETURNS void AS $$
BEGIN
    DELETE FROM auth.users
    WHERE is_anonymous = true
    AND (last_sign_in_at < NOW() - INTERVAL '90 days' OR (last_sign_in_at IS NULL AND created_at < NOW() - INTERVAL '90 days'));
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 4. Schedule the Jobs to run nightly at 3:00 AM UTC
-- Note: 'cron.schedule' will update the job if the name already exists
SELECT cron.schedule(
    'anonymize_stale_participants_nightly',
    '0 3 * * *',
    'SELECT fn_anonymize_stale_data();'
);

SELECT cron.schedule(
    'purge_inactive_guests_nightly',
    '0 3 * * *',
    'SELECT fn_delete_inactive_guests();'
);
