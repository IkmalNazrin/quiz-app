# ADR 007: UI Component Consistency & Asset Management

## Status
Approved

## Context
During the Phase 4 UI/UX polish, two regressions occurred:
1.  **Overwriting Core Logic**: The `AppIcons` class (Standard IconData) was accidentally overwritten by `AppSvgIcons` (SVG strings), breaking navigation in the `DashboardScreen`.
2.  **API Drifting**: `AppButton` was called with incorrect parameter names (`text` instead of `label`, `variant` instead of `type`), leading to compilation errors.

As the team grows and the design system evolves, we need strict rules to prevent these "quick fix" side effects.

## Decision
We implement the following discipline for UI and Asset management:

### 1. File Modification Safety
- **READ-BEFORE-WRITE**: Before updating a shared core file (like `app_icons.dart` or `design_system.dart`), the full file outline must be viewed to identify existing dependencies.
- **ADD-NOT-REPLACE**: Prefer adding new classes or extensions instead of modifying existing ones unless a refactor is explicitly planned.

### 2. UI Component Standardization
- **Naming Convention**: All UI components must use a standardized parameter set:
    - `label`: For the primary text content (not `text`, `title`, etc.).
    - `type`: For variant selection (not `variant`, `style`, etc.).
- **Docstrings**: All core widgets in `lib/core/presentation/widgets/` must have a constructor docstring.

### 3. Asset Dual-Management
- **AppIcons**: Reserved for standard `IconData` (Material/Cupertino).
- **AppSvgIcons**: Reserved for `String` SVG definitions used with `SvgPicture`.
- These classes must coexist in `app_icons.dart` to provide a single point of truth for all icons.

## Consequences
- **Positive**: Reduces "silly" compilation errors and regressions in core screens.
- **Positive**: Facilitates easier onboarding for new team members.
- **Negative**: Slightly slower implementation speed due to mandatory "outline checking".
