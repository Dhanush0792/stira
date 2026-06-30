# CONVENTIONS

## Coding Style
- **Modularity**: High separation of concerns. Pure logic is isolated from UI components.
- **Naming**: High readability with exceptional naming conventions and structured comments.

## UI / Design System
- **Aurora Glass Calm Interface System**: Glassmorphism is a primary theme (`StiraGlassCard`).
- **Colors**:
  - Background: `stiraBg` (#07060F)
  - Primary Accent: `stiraTeal` (#1ECFB3)
  - Other Accents: Pink, Amber, Violet
- **Typography**: Syne (Headlines), DM Sans (Body)
- **Design Tokens**: Enforced use of `StiraTokens` across all files.

## Patterns
- Screen definitions use `SafeArea` and `SingleChildScrollView` with `resizeToAvoidBottomInset` to handle dynamic keyboard rendering.
- State management relies strictly on Riverpod.
- Heavy analytical computations happen in `Isolate.run` to prevent UI jank.
