# CONCERNS

## Performance Considerations
- The UI relies heavily on `RadialGradient` and `Opacity` animations (e.g. `StiraOrb`), which may cause performance issues or jank on budget Android devices. Isolate analysis mitigates part of the computational impact, but rendering remains complex.

## Security Practices
- "Danger Zones" generated from locations are stored in cleartext locally using Hive. Although typical for mobile apps, it represents a potential data privacy concern for high-risk users. Security rules in Firestore are strict (granular match per user) but local device extraction exposes locations.

## Design / UX Weaknesses
- **Stability Index Complexity**: The calculation is multifaceted and users may find it hard to comprehend how specific actions affect the moving average index. A "Stability Tooltip" would make this clearer.
- **Engagement**: Low engagement mechanics for longer inactivity. If users do not interact for >48h, a single "System Drift" notification is triggered, which could be insufficient for retaining at-risk users.

## Feature Debt
- **Bond Mode**: Basic server logic and rules exist, but the client-side UI for inviting, accepting, and triggering relapse alerts via Bond Mode is fragmented or incomplete.
- **The Vault**: Supports basic string inputs but needs media support for richer experiences.
- **Premium Features**: A boolean `isPremium` exists without actual paywall integrations.
