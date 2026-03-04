# ADR 017: Guest Access via Anonymous Authentication

## Status
Proposed

## Context
The QuizApp's goal is to maximize engagement. Forcing users to create an account (Email/Google) before joining a quiz via a Game PIN is a high-friction barrier. However, we must maintain security (RLS), track scores, and support Realtime Presence, all of which rely on a valid `user_id`.

## Decision
We will support **Anonymous Authentication** for users joining quizzes without being logged in.

### Architecture Options Evaluated

| Option | Description | Pros | Cons |
| :--- | :--- | :--- | :--- |
| **1. Forced Login** | Current state. Users must sign in to join. | No development cost, highest data integrity. | High friction, lower user conversion. |
| **2. Anonymous Auth** | Use Supabase `signInAnonymously()`. | **Zero friction, supports RLS, clean "upgrade" path to full account.** | Requires Supabase configuration. |
| **3. Nullable User ID** | Allow `null` user_ids in `game_participants`. | Simple DB change. | Breaks RLS security, harder to track sessions. |

### Chosen Option: 2. Anonymous Auth
This alignment with industry standards for "Try before you buy" (or "Play before you pay/register") ensures that we can scale quickly without sacrificing the robustness of our data model.

## Consequences
- **Positive**: Seamless onboarding for players.
- **Positive**: Guest users can be converted to permanent accounts without losing history (requires future Account Linking implementation).
- **Negative**: Increases "Monthly Active Users" (MAU) in Supabase (though within free tier limits for now).
- **Neutral**: Requires clear UI communication that progress might be lost unless they create an account later.

## Implementation Notes
- Triggered automatically in the `joinGame` flow if no session exists.
- Requires `SUPABASE_AUTH_ANONYMOUS_SIGN_INS_ENABLED` to be toggled in the Supabase Dashboard.
- Future work: Add an "Upgrade Account" banner on the results screen for guests.
