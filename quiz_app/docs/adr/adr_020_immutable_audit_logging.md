# ADR 020: Immutable Organizational Audit Logging

## Status
Proposed

## Context
Phase 7 (Governance & Customization) requires an immutable system for tracking administrative organizational changes. While a basic `security_audit_logs` table exists, it is not strictly immutable (no database-level prevention of deletion), lacks organizational context (`organization_id`), and does not automatically capture changes to the organizational structure.

## Decision
We will enhance the existing `security_audit_logs` infrastructure to meet enterprise governance standards:

1.  **Schema Extension**: Add `organization_id` (UUID) and `user_agent` (TEXT) to `public.security_audit_logs`.
2.  **Immutability**: Implement a PostgreSQL trigger `tr_prevent_audit_modification` on `security_audit_logs` that raises an exception on any `UPDATE` or `DELETE` operations.
3.  **Enhanced Trigger Function**: Update `fn_log_audit_change()` to:
    *   Automatically detect and populate `organization_id` from the target record.
    *   Capture `User-Agent` from request headers.
4.  **Automated Coverage**: Apply the audit trigger to `public.organizations`, `public.organization_members`, and `public.webhooks`.

## Consequences
- **Positive**: Complies with administrative audit requirements for enterprise production.
- **Positive**: Simplifies Admin Dashboard development by allowing per-organization audit filtering.
- **Positive**: Prevents tampering with audit trails by malicious actors or accidents.
- **Negative**: Increased storage requirements as logs cannot be pruned (unless via a controlled retention process defined in future phases).
- **Negative**: Slight performance overhead on write operations for audited tables.

## Implementation Details
- **Detecting Org ID**: The trigger will check for `organization_id` in the `NEW`/`OLD` record, or use `id` if the table is `organizations`.
- **Request Metadata**:
    - `ip_address`: `current_setting('request.headers', true)::jsonb->>'x-real-ip'`
    - `user_agent`: `current_setting('request.headers', true)::jsonb->>'user-agent'`
