# ADR 015: Purple Midnight (Starry Night) Visual Overhaul

## Status
Proposed

## Context
The user wants a "Purple midnight color instead of default white like starry night" with a professional, gamified, and premium feel, including epic animations and iOS-style UI/UX.

## Decision
We will transition the application's primary aesthetic from the current light theme to a custom **"Midnight Oasis"** design system.

### 1. Color Palette (Midnight Oasis)
- **Background**: Deep Indigo/Black (`#0F172A` to `#1E1B4B` gradient).
- **Surface**: Translucent Purple/Navy (`#1E293B` or custom Glass).
- **Primary**: Electric Purple (`#8B5CF6`).
- **Secondary**: Cyber Teal (`#2DD4BF`).
- **Accent**: Neon Pink (`#F472B6`) for high-energy gamification elements.
- **Text**: Off-White/Silver (`#F8FAFC`, `#CBD5E1`).

### 2. "Starry Night" Background
- Implement a global `StarryBackground` widget that uses a subtle particle system or animated SVG stars behind the `Scaffold`.

### 3. iOS-Style Animations
- **Transitions**: Native `CupertinoPageRoute` for all navigation.
- **Micro-interactions**: Elastic scaling, haptic feedback on every tap, and soft-spring animations for modal reveals.
- **Staggered Entry**: All list components (Quizzes, Leaderboard) will use staggered fade+slide entry animations.

### 4. Professional Gamification
- Use high-quality gradients and "Glow" effects (Shadows with color matched to the element) to create a premium, high-stakes tournament feel.

## Rationale
- **Visual Impact**: A dark, high-contrast theme is often perceived as more "premium" and "pro" in gaming contexts.
- **Differentiated Brand**: Moving away from standard light-themed Material apps provides a unique identity.
- **Performance consideration**: Dark themes are generally easier on battery for OLED screens.

## Consequences
- **Positive**: Significantly increased "wow" factor.
- **Positive**: Better energy for gamified elements.
- **Negative**: Requires careful adjustment of all existing components to ensure text contrast and visibility.
- **Negative**: BackdropFilters (for glassmorphism) can be expensive; we will use them strategically.
