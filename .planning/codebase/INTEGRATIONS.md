# INTEGRATIONS

## Firebase Services
- Firebase Authentication (`firebase_auth`): Provides Email/Password signups and login logic, managed via `StiraAuthService`.
- Cloud Firestore (`cloud_firestore`): Syncs user profiles, check-in logs, relapse logs, dopamime journal, and vault fragments to the cloud (`users/{uid}`).
- Firebase Cloud Messaging (`firebase_messaging`): Powers push notifications for intelligent alerts, managed through FCM tokens.
- Firebase Crashlytics & Analytics: Collects telemetry, records fatal errors and core behavioral actions.

## Local Services
- Hive & Hive Flutter: High-performance NoSQL local DB for persisting `stira_prefs` (sleep history, settings, profiling) and `stira_logs`.
- Geolocator: Powers geofencing features (e.g. Danger Zones triggering SOS Heartbeats).
- Local Notifications (`flutter_local_notifications`): Timed reminders operating within allowed quiet hours.
- Local Auth (`local_auth`): Integrates with BiometricWallScreen to handle device-level locking.
