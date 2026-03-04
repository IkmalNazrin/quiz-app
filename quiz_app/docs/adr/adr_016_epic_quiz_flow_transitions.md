# ADR 016: Epic Quiz Flow Transitions

## Status
Proposed

## Context
The current quiz flow (Question -> Answer Reveal -> Leaderboard -> Final Results) is functional but lacks the high-impact "Epic" feel requested by the user. We need to define a consistent set of animations and UI patterns to elevate the gamification and professional quality of these transitions.

## Decision
We will implement an **"Impact-First"** transition strategy for the quiz flow.

### 1. The "Reveal" Pattern
- **Question Entry**: Questions will not just appear. They will use a staggered "Zoom + Fade" entry for the question card, followed by the options sliding in from the bottom with an elastic curve.
- **Answer Selection**: When an option is tapped, it will scale down slightly (haptic) and then glow intensely. Other options will dim.
- **Answer Reveal**: A 3-2-1 countdown or a "Pulse" effect will precede the reveal of the correct answer. The correct answer will then glow with a vibrant "Success" green, while incorrect ones will shake and turn translucent red.

### 2. The "Leaderboard Climb" Pattern
- **Mid-game Leaderboard**: Instead of a static list, we will use `ImplicitlyAnimatedList` or `AnimatedSwitcher` to show players moving up or down the rankings based on their new scores.
- **Points Pop-up**: Gained points will float up from the player's name with a "zoom-out" fade effect.

### 3. The "Grand Finale" Pattern
- **Podium reveal**: 3rd, 2nd, and 1st place will be revealed sequentially with increasing intensity of confetti and sound (if applicable) / haptics.
- **Summary Cards**: Final stats (accuracy, speed, longest streak) will be shown as high-fidelity Glassmorphic "Achievement Cards".

## Rationale
- **Engagement**: High-fidelity animations create a "dopamine hit" that keeps users engaged.
- **Professionalism**: Smooth, purposeful transitions are a hallmark of high-end iOS and gaming apps.
- **Clarity**: Purposeful animations guide the user's eye to the most important information (e.g., the correct answer, their new rank).

## Consequences
- **Positive**: Significantly enhanced gamification and "wow" factor.
- **Negative**: Increased complexity of widget state management.
- **Negative**: Potential for "animation fatigue" if transitions are too slow; we will keep them snappy (300-500ms).
