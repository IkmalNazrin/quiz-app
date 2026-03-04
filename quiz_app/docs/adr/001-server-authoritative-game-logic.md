# ADR 001: Server-Authoritative Game Logic

## Context
Initial prototypes relied on client-side timers for game progression. This was prone to synchronization issues (clock drift) and vulnerable to cheating (users could manually trigger "next question" by spoofing requests).

## Decision
Move the "heartbeat" of the game to Supabase Edge Functions (`game-orchestrator`).

## Consequences
- **Positive**: Harder to cheat; consistent timing across all devices; centralized scoring logic.
- **Negative**: Increased latency (network round-trip required to start rounds); requires Edge Function hosting.
- **Mitigation**: Added `PerformanceService` to monitor API latency.
