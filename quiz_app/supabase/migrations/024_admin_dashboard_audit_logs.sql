-- ==========================================
-- Migration: Admin Dashboard & Immutable Audit Logs (Phase 2 Enterprise)
-- ==========================================

-- 1. Extend security_audit_logs schema
ALTER TABLE public.security_audit_logs 
ADD COLUMN IF NOT EXISTS organization_id UUID REFERENCES public.organizations(id) ON DELETE CASCADE,
ADD COLUMN IF NOT EXISTS user_agent TEXT;

-- 2. Immutability Trigger
CREATE OR REPLACE FUNCTION public.fn_prevent_audit_modification()
RETURNS trigger AS $$
BEGIN
    RAISE EXCEPTION 'Audit logs are immutable and cannot be modified or deleted.';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS tr_prevent_audit_modification ON public.security_audit_logs;
CREATE TRIGGER tr_prevent_audit_modification
BEFORE UPDATE OR DELETE ON public.security_audit_logs
FOR EACH ROW EXECUTE FUNCTION public.fn_prevent_audit_modification();

-- 3. RLS Policy for Org Admins
DROP POLICY IF EXISTS "Admins can view audit logs" ON public.security_audit_logs;
DROP POLICY IF EXISTS "Org Admins can view org audit logs" ON public.security_audit_logs;

CREATE POLICY "Org Admins can view org audit logs" ON public.security_audit_logs
FOR SELECT USING (
    EXISTS (
        SELECT 1 FROM public.organization_members
        WHERE public.organization_members.organization_id = public.security_audit_logs.organization_id
          AND public.organization_members.user_id = auth.uid()
          AND public.organization_members.role IN ('admin', 'owner')
    )
);

-- We keep the existing "Users can insert their own audit logs" policy if it exists,
-- but we might want to also allow organization members to insert. Typically this is 
-- done via SECURITY DEFINER functions or triggers.

-- 4. Automated Change Data Capture (CDC) Triggers

-- For Organizations
CREATE OR REPLACE FUNCTION public.fn_log_org_change()
RETURNS trigger AS $$
DECLARE
    v_org_id UUID;
BEGIN
    IF TG_OP = 'DELETE' THEN
        v_org_id := OLD.id;
    ELSE
        v_org_id := NEW.id;
    END IF;

    INSERT INTO public.security_audit_logs (organization_id, user_id, event_type, details)
    VALUES (
        v_org_id,
        auth.uid(),
        'ORGANIZATION_' || TG_OP,
        jsonb_build_object(
            'table', TG_TABLE_NAME,
            'operation', TG_OP,
            'old_record', row_to_json(OLD),
            'new_record', row_to_json(NEW)
        )
    );
    
    IF TG_OP = 'DELETE' THEN
        RETURN OLD;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS tr_log_org_change ON public.organizations;
CREATE TRIGGER tr_log_org_change
AFTER INSERT OR UPDATE OR DELETE ON public.organizations
FOR EACH ROW EXECUTE FUNCTION public.fn_log_org_change();


-- For Organization Members
CREATE OR REPLACE FUNCTION public.fn_log_org_member_change()
RETURNS trigger AS $$
DECLARE
    v_org_id UUID;
BEGIN
    IF TG_OP = 'DELETE' THEN
        v_org_id := OLD.organization_id;
    ELSE
        v_org_id := NEW.organization_id;
    END IF;

    INSERT INTO public.security_audit_logs (organization_id, user_id, event_type, details)
    VALUES (
        v_org_id,
        auth.uid(),
        'ORG_MEMBER_' || TG_OP,
        jsonb_build_object(
            'table', TG_TABLE_NAME,
            'operation', TG_OP,
            'old_record', row_to_json(OLD),
            'new_record', row_to_json(NEW)
        )
    );
    
    IF TG_OP = 'DELETE' THEN
        RETURN OLD;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS tr_log_org_member_change ON public.organization_members;
CREATE TRIGGER tr_log_org_member_change
AFTER INSERT OR UPDATE OR DELETE ON public.organization_members
FOR EACH ROW EXECUTE FUNCTION public.fn_log_org_member_change();
