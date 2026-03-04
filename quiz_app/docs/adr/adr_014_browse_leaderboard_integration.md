# ADR 014: Browse Leaderboard Integration

## Context
The user wants to see a leaderboard (individual and teams) for each quiz on the "Browse" page and be able to challenge others from that leaderboard.

## Decision
We will implement an **Expandable Leaderboard Preview** within the quiz cards on the Browse page.

### Rationale
- **Context Preservation**: Users can see the leaderboard without navigating away from the Browse page.
- **Visual Impact**: Interactive cards that expand feel more premium and modern.
- **Efficiency**: Fetching data only on expansion prevents overloading the backend with requests for every quiz in the list.

### Implementation Details
1. **Compact UI**: The preview will show only the top 3-5 players/teams.
2. **Toggle Mechanism**: A simple tab or switch within the card will toggle between Individual and Teams.
3. **Challenge Hook**: The "Challenge" action will trigger the existing `ChallengeLoadingScreen`.

## Alternatives Considered
- **Full Page Navigation**: Redirecting to the existing `LeaderboardScreen`. (Rejected: Too disruptive for "browsing").
- **Modal View**: Showing the leaderboard in a dialog. (Rejected: Less integrated feel than expandable cards).

## Consequences
- Need to handle layout transitions smoothly (using `flutter_animate`).
- Need to manage data state for each quiz card's leaderboard preview.
