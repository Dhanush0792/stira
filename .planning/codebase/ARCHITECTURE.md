# ARCHITECTURE

## Layered Predictive Architecture
The app follows a Predictive Architecture with distinct layers:

1. **Data Layer**: 
   - Hive (Local persistence for check-ins, prefs)
   - Firestore (Cloud Sync for user profiles, logs, vault)

2. **Logic Layer**: 
   - `BehaviorEngine` & `BehaviorService`: Uses isolates to analyze time density, isolation amplifier, fatigue influence, and recovery trends.
   - `RiskEngine`: Calculates a 0-10 risk score (Low, Moderate, Elevated, Critical) using base urge and modifiers.

3. **Coordination Layer**:
   - `IntelligenceLayer`: Riverpod `StateNotifier` that aggregates logic. Selects `BehaviorMode` and `SuggestedAction`.
   - `AdaptiveScheduler`: Manages the timing and frequency of notifications based on user behavior and quiet hours.

4. **UI Layer**:
   - Multi-tab IndexedStack interface.
   - Aurora Glass Calm Interface System with glassmorphism UI.

## Data Flow
- User Check-in -> Data Layer (Hive) -> Logic Layer analyzes inputs -> Intelligence Layer updates the global `StabilityIndex` -> UI updates (Orb, Forecast, Dial).
