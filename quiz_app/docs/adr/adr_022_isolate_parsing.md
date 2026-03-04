# ADR 022: Background JSON Parsing via Isolates

## Context
As the Quiz App scales and handles larger datasets (e.g., fetching lists of quizzes, organization members, game histories, or complex analytics data), the JSON deserialization process (`fromJson` calls and `jsonDecode`) is currently executing on the main UI thread. 

In Flutter, the main isolate is responsible for layout, painting, and interacting with the native platform. When heavy synchronous computation like iterating and mapping large JSON payloads blocks the main thread, the application drops frames, leading to scrolling jank and staggered animations. This violates our standard for an "Epic UI/UX" with 120Hz smooth operations.

## Options Considered

### 1. Synchronous Main-Thread Parsing (Current Approach)
- **Pros:** Simplest code, easy to test, no concurrency overhead.
- **Cons:** Blocks the main thread. Unacceptable for lists larger than a few items or deeply nested structures.

### 2. Legacy `compute()` Function
- **Pros:** Standard Flutter API, effectively offloads work to a background isolate.
- **Cons:** Requires top-level or static functions because the function passed to `compute` must be an independent entry point. This leads to boilerplate "helper" functions polluting files.

### 3. Modern Dart `Isolate.run()` (Dart 2.15+)
- **Pros:** Allows passing closures directly. No need for top-level or static functions. Much less boilerplate. Extremely efficient memory transfer since Dart 2.15 (worker isolates can transfer data ownership to the main isolate in O(1) time without copying).
- **Cons:** Slight overhead to spawn an isolate (typically < 10ms). Should only be used for collections or complex objects, not trivial solitary objects.

## Decision
We will standardize on **Option 3: `Isolate.run()`** for all heavy JSON parsing operations moving forward.

### Constraints & Rules
1. **Use specifically for Lists/Collections:** Single object mapping (e.g., getting a single User profile on login) is often faster synchronously due to the small overhead of spawning an isolate. `Isolate.run()` MUST be used when mapping `List<dynamic>` to our model classes.
2. **Immutable Data:** The closure passed to `Isolate.run()` should only operate on data passed into it, returning the newly constructed immutable objects.
3. **Layer location:** This isolate usage should be encapsulated within the **Data Layer** (DataSources or Repositories) or specific **UseCases** dedicated to data transformation. The Presentation layer (UI/Notifiers) should never be aware of Isolates.

## Consequences
- **Positive:** Immediate improvement in frame rates during network fetches. No more main-thread blocking when paginating through large history lists or leaderboards.
- **Negative:** Minor increase in code complexity wrapping Future calls in `Isolate.run()`. Unit tests might require minor adjustments if they mock isolating behavior incorrectly, though Dart typically handles this transparently in modern test environments.

## Status
Accepted 
