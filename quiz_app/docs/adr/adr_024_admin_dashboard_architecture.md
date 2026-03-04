# ADR 024: Admin Dashboard & Immutable Audit Logs Architecture

## Status
Proposed

## Context
As part of Phase 2 Enterprise Hardening, we are required to build an Admin Dashboard for Organization Managers, emphasizing Role-Based Access Control (RBAC) and immutable `security_audit_logs`. 

The current database schema for `security_audit_logs` (from Migration 006) lacks an `organization_id` column, making it impossible to segment audit logs securely by organization. Furthermore, there is no database-level protection preventing the modification or deletion of these logs (Immutability). The frontend `AdminDashboardScreen` and `AuditLogsView` are partially stubbed and attempt to filter by `organization_id`, but this will fail until the database aligns with these enterprise requirements.

## Decision
We will upgrade the `security_audit_logs` infrastructure and formalize the Admin Dashboard data flow using the following architectural approach:

### 1. Database Schema Extension (Security Audit Logs)
- Add `organization_id` (UUID) to `public.security_audit_logs`.
- Add `user_agent` (TEXT) to capture request metadata alongside the existing `ip_address` field.
- Apply a foreign key constraint linking `organization_id` to `public.organizations` (or rely on application-level integrity if `organizations` is handled differently, though strict relational integrity is preferred).

### 2. Strict Immutability via PostgreSQL Triggers
- Create a trigger function `fn_prevent_audit_modification()` that raises a strict SQL exception (`RAISE EXCEPTION 'Audit logs are immutable'`) if any `UPDATE` or `DELETE` operation is attempted on the `security_audit_logs` table.
- Attach this trigger (`tr_prevent_audit_modification`) to `public.security_audit_logs`.

### 3. Role-Based Access Control (RLS) for Organizations
- Implement Row Level Security (RLS) policies on `security_audit_logs` ensuring that:
  - Users can read logs ONLY IF their `auth.uid()` belongs to the `organization_members` table for the specific `organization_id` AND their role is `admin` or `owner`.
  - System edge functions (Service Role) bypass RLS for automated logging.

### 4. Automated Change Data Capture (CDC)
- Implement a generic trigger `fn_log_audit_change()` attached to `public.organization_members`, `public.webhooks`, and `public.organizations`. 
- This trigger will automatically insert a row into `security_audit_logs` upon `INSERT`, `UPDATE`, or `DELETE`, storing the `OLD` and `NEW` records in the `details` JSONB column. This prevents application-level code from forgetting to log critical RBAC or configuration changes.

### 5. Frontend Architecture (Admin Dashboard)
- The Flutter application will continue using Riverpod for state management (`organizationRepositoryProvider`).
- The `AuditLogsView` will query the `security_audit_logs` table filtering by the `activeWorkspaceProvider`'s `organizationId`. Server-side evaluation of RLS guarantees that malicious API requests lacking proper RBAC privileges will return empty arrays.

## Consequences
- **Positive**: Hardened enterprise compliance. Audit logs become tamper-proof at the database engine level.
- **Positive**: Organization Managers get instant, reliable visibility into team mutations via the Admin Dashboard.
- **Positive**: Automated triggers reduce the burden on the Flutter client or Edge Functions to manually insert audit logs for every admin action.
- **Negative**: Increased storage footprint as every RBAC mutation generates JSONB audit trails that cannot be deleted.

## Implementation Details
The next migration script (`024_admin_dashboard_audit_logs.sql`) will encode these schema changes, triggers, and RLS policies. The Flutter client will require minimal changes as the `OrganizationRemoteDataSourceImpl` already expects this structure, but we will write integration tests to verify the RLS and trigger enforcement.
