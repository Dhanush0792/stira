# STRUCTURE

## Directory Layout
- `lib/core/`
  - Central logic, engines (`BehaviorEngine`, `RiskEngine`), `IntelligenceLayer`, routes, common widgets.
- `lib/features/`
  - UI screens organized by functionality:
    - Onboarding (`WelcomeScreen`, `OnboardingAssessment`, `SignupScreen`)
    - Dashboard (`HomeTab`, Check-in flows, Urge Surfing)
    - Insights (Pattern reflection, Triggers)
    - Tools (The Vault, Dopamine Journal, SOS Flow)
    - Profile (Account, Bond Mode settings)
- `lib/services/`
  - Infrastructure and external integrations (Auth, Notification, Storage/Hive).
- `lib/theme/`
  - Visual design tokens (`StiraTokens`) and themes.

## Key Entry Points
- `main.dart`: App initialization, Firebase setup, initial routing based on auth and onboarding state.
- `MainNavigation`: Uses `IndexedStack` to manage the 4 main tabs (Home, Insights, Tools, Profile).
