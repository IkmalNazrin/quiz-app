# ADR 009: JSON Resilience Pattern for Sub-Relational Data

## Status
Proposed

## Context
In ADR 008, we introduced `jsonb` columns (e.g., `teams`) to persist complex game state. During implementation, a mismatch between the database default (`[]`) and the application's domain expectation (`Map<String, List>`) caused a "Launch Arena" crash. 

As an enterprise application, schema drift or manual DB edits must not be a single point of failure that crashes the UI.

## Decision
We will enforce a **JSON Resilience Pattern** for all non-relational fields stored in Supabase:

### 1. Defensive Type Guarding
Domain entities must not assume the type of a JSONB field. The `fromMap` factory must use type guards:
```dart
// Example
teams: map['teams'] is Map 
    ? Map<String, dynamic>.from(map['teams'] as Map) 
    : {}, // Fail-safe default
```

### 2. Explicit Default Sync
Database defaults and Entity defaults must be documented together. If an Entity expects a `Map`, the SQL column MUST default to `'{}'::jsonb`.

### 3. Graceful Transformation
If the incoming JSON is malformed or of an unexpected type, the system should log a warning to a telemetry service (e.g., Sentry) but proceed with a valid "empty" state rather than throwing an unhandled exception.

## Consequences
- **Positive**: Prevents application crashes due to schema/code desynchronization.
- **Positive**: Allows for easier migrations (app handles old/new formats gracefully).
- **Negative**: May hide logic errors if valid data is "swallowed" by defaults.
- **Mitigation**: Robust logging via `AppLogger` is mandatory for failed casts.
