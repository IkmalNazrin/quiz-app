# ADR 001: Feature-First Clean Architecture

## Status
Approved

## Context
The QuizApp is a real-time multiplayer application requiring high responsiveness, maintainability, and testability. As the system grows, a flat structure or "folders-by-type" (MVVM) approach leads to cross-feature coupling and difficult-to-maintain files.

## Decision
We adopt **Feature-First Clean Architecture** as the primary architectural pattern.

### 1. Folder Structure
The `lib/` directory shall be organized as follows:
- `core/`: Cross-cutting concerns (Design System, Services, Extensions).
- `features/`: Business logic modularized by feature.
  - `feature_name/`
    - `domain/`: Entities (POJOs), Use Cases, Repository interfaces. **Dependencies: None.**
    - `data/`: DTOs, Repository implementations, Data Sources. **Dependencies: Domain.**
    - `presentation/`: Widgets, State management (Providers/BLoC). **Dependencies: Domain.**

### 2. Dependency Rule
Dependencies must point **inwards** toward the Domain layer.
- `Data` depends on `Domain`.
- `Presentation` depends on `Domain`.
- `Domain` depends on **nothing** (it defines the interfaces).

### 3. State Management
- Use `flutter_riverpod` or `Provider` for reactive state.
- Screen states must be encapsulated in separate state classes (e.g., `GameState`).

## Consequences
- **Positive**: Isolated testing of business logic without mocking UI or external APIs.
- **Positive**: Features can be modified or replaced without affecting others.
- **Negative**: Increased "boilerplate" (Entities vs Models vs Use Cases).
- **Negative**: Higher initial setup time for new features.
