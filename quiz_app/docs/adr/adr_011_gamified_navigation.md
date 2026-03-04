# ADR 011: Gamified Navigation & Dashboard Revamp

## Status
Proposed

## Context
The current navigation in the `DashboardScreen` uses the standard Flutter `BottomNavigationBar`. While functional, it feels "stock" and doesn't align with the premium, gamified aesthetic defined in ADR 002. Specifically:
- The "Play" action (the most important feature) is hidden among other tabs.
- The profile button is in the AppBar, making it less discoverable and requiring extra reach.
- The transition between tabs lacks the "epic" feel desired by users.

## Decision
We will implement a custom navigation architecture to elevate the UX:

1.  **Custom Notched Navigation Bar**: Create a `GamifiedNavBar` that uses a `CustomPainter` to draw a professional, curved notch for a central action button.
2.  **Central "Epic" Play Button**: Elevate the "Play" action to a large, animated button nested in the navigation bar's notch. This button will include:
    - Gradient styling and elevation.
    - Subtle pulse animations while idle.
    - Interaction feedback (scale/rotation).
3.  **Integrated Profile Tab**: Move profile navigation into the main bottom bar for better accessibility.
4.  **Refined Tab Indices**: Shift from a 4-item to a 5-item layout:
    - Index 0: Browse (Discovery)
    - Index 1: Social (Engagement)
    - Index 2: Primary Action (Play)
    - Index 3: Workshop (Creation)
    - Index 4: Profile (Identity)

## Consequences
- **Positive**: Stronger visual identity and "premium" product feel.
- **Positive**: Improved ergonomics (all primary actions within thumb reach).
- **Positive**: Prominent "Play" button reinforces the primary app loop.
- **Negative**: Requires custom UI development and custom painting (higher maintenance than stock components).
- **Negative**: Layout density increases on smaller devices.
