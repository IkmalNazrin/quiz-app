# ADR 008: Supabase Realtime Migration for Gameplay

## Status
Proposed

## Context
The legacy gameplay logic relies on a standalone Node.js server and Socket.io. This introduces several production risks:
1. **Infrastructure Fragility**: Requires maintaining a separate Node.js/MongoDB stack.
2. **Context Switching**: Authentication and data reside in Supabase, but real-time logic is external.
3. **Volatile State**: Game state is held in memory on the Node server; if the server restarts, all active games are lost.

## Decision
We will migrate all real-time gameplay logic to **Supabase Realtime**.

### 1. Unified Infrastructure
By moving to Supabase Realtime, we consolidate the entire backend into a single serverless infrastructure, reducing operational overhead and improving security through consistent RLS policies.

### 2. Stateful Management
- **Game Sessions**: The source of truth for any game moves from Node.js memory to the `game_sessions` table.
- **Participant Tracking**: We will use **Presence** for "heartbeat" tracking (who is currently online) and the `game_participants` table for durable score/membership recording.

### 3. Event Broadcasting
- We will use **Supabase Channels (Broadcast)** for low-latency, non-persistent events like "New Question" and "Timer Sync".
- The Host will act as the "Master" node for these broadcasts to maintain simplicity without a backend worker.

### 4. Repository Contract Update
The `GameRepository` will be updated to return state-confirming `Future`s instead of the previous fire-and-forget emitter pattern.

## Consequences
- **Positive**: Simplified architecture (1 less server to manage).
- **Positive**: Persistent game state (sessions can survive host temporary disconnection).
- **Positive**: Native integration with existing Supabase Auth.
- **Negative**: Increased complexity in handling "Master" node failures (Host disconnecting).
- **Negative**: Migration requires updating all real-time listeners in the UI layer.
