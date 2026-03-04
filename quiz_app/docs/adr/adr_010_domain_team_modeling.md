# ADR 010: Domain-Driven Team Modeling

## Status
Proposed

## Context
In the initial prototype, game teams were managed as `Map<String, dynamic>` where keys are team names and values are lists of user IDs. This approach lacks type safety, making the codebase prone to runtime errors during team manipulation (randomization, assignment). Furthermore, it relies on primitive data structures that don't reflect the domain's language.

## Decision
We will formalize team modeling by introducing dedicated domain entities:

1. `TeamMember`: Wraps participant data relevant to team context.
2. `Team`: Encapsulates team identity (`name`) and its composition (`List<TeamMember>`).
3. `GameEntity` integration: The `teams` field will use `List<Team>` for unified handling and easier iterative operations.

## Mapping Logic
- **Domain to Data**: `List<Team>` -> `Map<String, List<String>>` (for JSONB storage in Supabase).
- **Data to Domain**: `Map<String, dynamic>` -> `List<Team>` (with ADR 009 defensive parsing).

## Consequences
- **Positive**: Improved type safety and IDE autocomplete.
- **Positive**: Centralized parsing logic reduces bug surface area.
- **Positive**: Business logic (e.g., randomization) becomes cleaner when operating on typed lists.
- **Negative**: Adds slight overhead in mapping between layers.
