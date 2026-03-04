# ADR 013: Global Premium UI/UX Design Language

## Status
Proposed

## Context
The user has requested a "professional, premium, iOS feel" across all pages. Our current UI is functional but leans heavily on standard Material components and simplistic container patterns. To create a cohesive, high-end experience, we must establish a consistent "Design Language" that applies across the entire app.

## Decision
We will adopt a "Glass & Light" design system with the following global standards:

1.  **Glassmorphism (Frosted Glass) Foundation**:
    - Every screen header (AppBar area) will use a `GlassHeader` component (BackdropFilter + Opacity).
    - Modals and Overlays will also use glassmorphic backgrounds to create depth.

2.  **Premium Interaction Feedback**:
    - **Haptics**: Universal adoption of `HapticFeedback` for all button presses, list selections, and state changes (correct/incorrect answers).
    - **Scaling**: All interactive cards (`AppCard`) and buttons (`AppButton`) will subtely scale down (0.98x) on tap.

3.  **Advanced Motion Palette**:
    - **Staggered Lists**: Every list view (Quizzes, Teams, Participants) will implement staggered animations.
    - **Micro-animations**: Use pulse, shimmer, and shake effects sparingly but effectively for status indicators (e.g., "Waiting for Host", "Low Time").
    - **Smooth Transitions**: Ensure `CupertinoPageRoute` is used globally for iOS-style entry/exit.

4.  **Gamification & Visual Depth**:
    - Higher frequency of gradients (`primaryGradient`, `streakGradient`, and new difficulty-based gradients).
    - Use of "Glow" effects (BoxShadow with high blur and low opacity matching component colors).
    - Rich iconography with consistent stroke weights.

5.  **Typography Overhaul**:
    - Strict adherence to `AppTypography` with increased line-heights for better readability.
    - Use of semi-bold weights for emphasis to mimic iOS HIG.

## Rationale
- **Consistency**: A global design language ensures the app feels like a single, polished product rather than a collection of screens.
- **Perceived Value**: Premium visuals and precise haptics elevate the perceived quality and "revenue-impact" potential of the app.
- **Maintainability**: Moving patterns into core widgets prevents "UI drift" during future development.

## Consequences
- **Positive**: High-end look and feel that differentiates the app in the market.
- **Positive**: More intuitive and responsive user interactions.
- **Negative**: Increased CPU/GPU usage from BackdropFilters (mitigated by prudent use of ClipRect).
- **Negative**: Longer initial implementation time per screen.
