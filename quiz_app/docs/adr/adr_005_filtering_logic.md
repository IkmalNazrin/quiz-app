# ADR 005: Category Filtering Architecture

## Status
Proposed

## Context
The "Browse" page features category filters (Science, History, etc.) that are currently purely visual and non-interactive. To support a production-grade discovery experience, these filters must:
1.  Be backed by real data in the database.
2.  Maintain local state for the user's selection.
3.  Trigger reactive list updates.

## Decision
We will implement **State-Driven Multi-Layer Filtering**.

### Architecture Options Evaluated

| Option | Description | Pros | Cons |
| :--- | :--- | :--- | :--- |
| **1. Local String Filtering** | Filter by searching the `title` or `description` strings. | No DB changes needed. | Fragile, inaccurate, doesn't scale well. |
| **2. Client-Side Only Category** | Mock categories in the Dart model only. | Fast frontend fix. | Inconsistent data; harder to manage via CMS/Admin. |
| **3. Full-Stack Category Support** | Add `category` column to DB, update Domain/Data layers, and use Riverpod for state. | **Cleanest, most robust, facilitates better SEO/Discovery features.** | Requires migration and multi-layer updates. |

### Chosen Option: 3. Full-Stack Category Support
This aligns with our **ENTERPRISE PRODUCTION MODE** by ensuring data integrity and a clear flow of information from DB to UI.

## Consequences
- **Positive**: Accurate filtering, extensible system (can later add sub-categories), cleaner UI logic.
- **Negative**: Requires small database migration and update to data models.

## Implementation Details
- **Schema**: Add `category TEXT` to `public.quizzes`.
- **State Management**: Use a `StateProvider<String>` in Riverpod to track the active category (defaulting to 'All').
- **UI**: Replace static `Chip` with interactive `FilterChip` or `ChoiceChip`.
- **Filtering Logic**: The `publicQuizzesProvider` will be modified or a new `filteredQuizzesProvider` will be introduced to combine the raw list with the selected category.
