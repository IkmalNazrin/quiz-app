# ADR 026: Production Security Remediation Decisions

**Date**: 2026-03-02
**Status**: Accepted

## Context
A comprehensive production readiness audit identified 12 findings across security, architecture, and correctness. This ADR documents the architectural decisions made during the remediation phase to ensure uniform understanding across the team.

## Decisions

### 1. DI Composition Root Exception
**Decision**: `app_providers.dart` is explicitly designated as the universal Dependency Injection (DI) Composition Root.
**Rationale**: `ARCHITECTURE.md` strictly forbids direct importation of vendor packages (e.g., `supabase_flutter`) into the application domain or core UI layers. However, the DI layer must instantiate concrete infrastructure implementations to bind them to domain interfaces. Therefore, `app_providers.dart` is the *single explicit exception* to this architectural boundary rule.

### 2. Device Integrity Gate (Fail-Closed)
**Decision**: The application will halt startup and render a dead-end `CompromisedDeviceApp` screen if `DeviceIntegrityService` reports the device is compromised.
**Rationale**: Previously, the service was called but the result was ignored (fail-open), violating ADR 021. While a hard block might yield false positives on custom ROMs, the business requirement for competitive integrity in a real-money/high-stakes quiz environment necessitates a "fail-closed" security posture.

### 3. API Rate Limiting via Token Bucket
**Decision**: Client-side API rate limiting is enforced via a `RateLimitedApiClient` wrapper injected into all Supabase remote data sources.
**Rationale**: The `RateLimiter` class (Token Bucket algorithm) existed but was unused. By wrapping the `SupabaseClient`, we ensure all repository operations (RPCs, queries, inserts) consume tokens before network execution, mitigating client-side spam and accidental DDoS from runaway loops.
**Default Configuration**: 30 max tokens, refilling every 1 second. 

### 4. Anonymization Before Deletion Flow
**Decision**: The `delete-user-account` edge function now explicitly anonymizes user profile data (name, email, avatar) in the public `users` table *before* invoking `auth.admin.deleteUser()`.
**Rationale**: `auth.admin.deleteUser()` can trigger cascading deletes depending on FK constraints. To preserve historical game analytics per ADR 021, we must guarantee PII is scrubbed while leaving the relational records (game answers, scores) intact. This two-phase approach guarantees data sanitization even if the auth record deletion fails.

## Consequences
- Testing infrastructure services requires passing a `RateLimitedApiClient` mock instead of a raw `SupabaseClient` mock.
- Support teams must be trained to handle user complaints regarding "Access Denied" screens on false-positive jailbreak detections.
