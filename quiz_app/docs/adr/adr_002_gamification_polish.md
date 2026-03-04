# ADR 002: Phase 4 - Excellence & Gamification

## Status
Proposed

## Context
The QuizApp has reached architectural stability (Phase 3). While functional and organized, the user experience lacks the "premium" feel and high-engagement mechanics required for a production-grade competitive app. To transition from a functional tool to an engaging product, we need to implement advanced feedback systems and gamification loops.

## Decision
We will implement "Excellence & Gamification" through three core pillars: **Sensory Feedback**, **Progression Mechanics**, and **Visual Polish**.

### 1. Sensory Feedback (The "Juicy" UX)
- **Haptic Tiering**: Implement nuanced haptics using `HapticFeedback`.
    - Correct Answer: `vibrate` (success pulse).
    - Incorrect Answer: `heavyImpact` (thud).
- **Celebratory Effects**: Integrate the `confetti` package for podium finishes.
- **Rich State Overlays**: Animated overlays for "Correct" and "Incorrect" responses to provide immediate reinforcement.

### 2. Progression & Engagement Loop
- **Streak System**: Track consecutive correct answers in the `GameSessionProvider`. Display a "Streak Fire" icon that grows as the streak continues.
- **Dynamic Progress**: Replace static "Question X/Y" text with a sleek, animated linear progress bar.
- **XP Recap**: Provide a visual breakdown of XP/Points gained at the end of each round (e.g., Speed Bonus, Streak Bonus).

### 3. Visual Polish (The "Wow" Factor)
- **Glassmorphism 2.0**: Enhance dialogs and overlays with backdrop filters.
- **Premium Micro-animations**: Use `flutter_animate` for more complex sequences (e.g., the answer options sliding in with staggered delays and slight rotations).
- **Custom Illustrations**: Replace generic icons with generated rich assets (SVGs) for key states (e.g., an empty search state, a "Joining Game" illustration).

## Consequences
- **Positive**: Significantly higher user retention and perceived value.
- **Positive**: Differentiates the app from generic quiz platforms.
- **Negative**: Increased complexity in state management (tracking streaks/bonuses).
- **Negative**: Potential performance impact on lower-end devices due to rich animations (mitigated by using `flutter_animate` efficiently).
