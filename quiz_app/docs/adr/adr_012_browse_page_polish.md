# ADR 012: Browse Page UI/UX Polish

## Status
Proposed

## Context
The current `BrowseScreen` provides a functional list of quizzes but lacks the visual depth and interactive "spark" required for a premium production app. To ensure a professional "iOS feel" (as requested in our Enterprise Production Mode), we need to transition from standard Flutter patterns to more sophisticated UI techniques.

## Decision
We will enhance the `BrowseScreen` with the following design patterns:

1.  **Glassmorphism (Frosted Glass) Header**:
    - Use `BackdropFilter` and `ClipRect` for the search/filter area.
    - This allows the quiz list to scroll behind the translucent header, a signature iOS design pattern.
2.  **Staggered Interactive Animations**:
    - Implement list animations where each card slides and fades in with a sequential delay.
    - Use `flutter_animate` for consistent timing.
3.  **Enhanced QuizCard Experience**:
    - Add `ScaleTransition` or `AnimatedContainer` response on tap/press.
    - Improve visual hierarchy: clearer fonts, richer gradients in the header, and interactive icons.
4.  **Gamification Cues**:
    - "Popularity" badges using the `streakGradient`.
    - "Difficulty" levels (e.g., Easy, Medium, Hard) represented by color-coded gradients.
    - Skeleton loaders for better perceived performance during data fetching.
5.  **Clean Component Extraction**:
    - Refactor the current monolithic screen into smaller, testable widgets: `BrowseSearchHeader`, `CategoryFilterBar`, and `InteractiveQuizCard`.

## Rationale
- **User Engagement**: Gamification badges and interactive feedback loops (haptics + scaling) increase the "fun" factor.
- **Brand Identity**: Moving away from stock Material feel establishes a unique, premium brand.
- **Maintainability**: Separating logic into discrete components makes the UI easier to evolve.

## Consequences
- **Positive**: Significantly improved "first impression" for new users.
- **Positive**: More responsive and fluid navigation.
- **Negative**: Increased complexity in the UI layer.
- **Negative**: Slight performance overhead from `BackdropFilter` (must be used carefully with `ClipRect`).
