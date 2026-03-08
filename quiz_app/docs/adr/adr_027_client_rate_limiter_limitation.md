# ADR 027: Client-Side Rate Limiter — Known Limitation

## Status
Accepted

## Context

The application uses a token-bucket `RateLimiter` class (in `quiz_infrastructure`) as a client-side guard, wired via `rateLimiterProvider` in `app_providers.dart`:

```dart
final rateLimiterProvider = Provider<RateLimiter>((ref) => RateLimiter(
  maxTokens: 30,
  refillInterval: const Duration(seconds: 1),
));
```

This limiter is **in-memory** and **non-persistent** — it resets to a full bucket every time the app is restarted.

## Decision

We accept this limitation as a **known and documented trade-off**, not a critical security gap.

### Rationale

1. **Server-side rate limiting is the real enforcement boundary.** The `check_rate_limit` RPC (migration `026_rate_limiting.sql`) is a DB-backed rate limiter enforced by the `game-orchestrator` Edge Function on every game action. A client restarting the app to reset its local bucket still hits the server-side limit.

2. **The client-side limiter is defense-in-depth only.** Its purpose is to prevent *accidental* runaway loops in client code from creating network storms — not to prevent adversarial bypass.

3. **Persistent local rate limiting would require SQLite state**, adding non-trivial complexity for a defense-in-depth guard. The cost outweighs the marginal security benefit.

## Consequences

### Positive
- Current design prevents accidental client-side API spam during normal operation.
- Zero additional infrastructure overhead.

### Negative
- Adversary can bypass the client-side limit by force-quitting and reopening the app.
- **Mitigation**: Server-side `check_rate_limit` RPC remains the authoritative enforcement.

## Rule Established

> **Rule**: Do NOT add persistence to the client-side `RateLimiter` without a concrete evidence-based case that current server-side enforcement is insufficient. The server is always the enforcement boundary.
