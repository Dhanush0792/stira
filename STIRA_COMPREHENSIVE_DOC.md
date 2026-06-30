# Stira — Comprehensive App Documentation

## 1. App Purpose & Overview
**App Name:** Stira
**Purpose:** A high-end behavioral analysis and pornography reduction mobile application.
**Platform:** Flutter (Android & iOS)
**Architecture:** 100% Local-First. Zero Firebase Cloud Functions or backend costs. Data stays on the device.

## 2. Design & Aesthetics
**Theme:** Premium dark glassmorphism aesthetic.
**Color Palette:**
- **Backgrounds:** Deep Space `bgDeep` (#07060F), Card Background `bgCard` (#0D0B1A)
- **Accents:** Pink (#E8307A), Teal (#1ECFB3), Amber (#F5A623), Violet (#7C4DFF). Used dynamically based on context.
- **Glass UI elements:** Minor white opacities for text and borders to create a blurred glass effect.
- **Typography:**
  - Display/Headings: **Syne** (Weights 700, 800)
  - Metrics/Numbers: **DM Mono** (Weights 400, 500)
  - Body/Descriptions: **DM Sans** (Weights 300, 400)

## 3. Screens & User Flow

### 3.1 Splash Screen
- Features a pulsing gradient orb (Pink/Violet) on a deep background.
- "Stira" title in Syne, tagline in DM Mono.

### 3.2 Onboarding
- Background features a pink radial glow.
- Progress bar uses animated pill segments.
- Selection buttons are GlassCards that highlight pink with glows upon selection.

### 3.3 Authentication / Sign Up
- **Privacy First:** "Your data stays on your device." No cloud database required for core logic.
- **Inputs:** Email and password fields using Glass UI styling.
- **Options:** Native Google and Apple social login buttons built-in.

### 3.4 Dashboard (Home View)
- The core of the app featuring the **Stira Orb**, an interactive and animating centerpiece representing the user's current behavioral state.
- **Displays:**
  - Active Streak (Pink LED)
  - Stability Score (Teal LED)
  - Forecast (Amber card showing vulnerable windows)
- **Actions:** Quick access to Check-in, Pause, and Reset buttons.

### 3.5 Daily Check-In
- Incorporates a unique **Radial Dial** (like a sensor scan) to log Urge Intensity (1-10 scale).
- **Questions:** Identifies trigger (e.g., Boredom, Stress) and energy levels.
- **Mechanism:** Answers are stored locally in Hive to update the intelligence engine dynamically.

### 3.6 Insights & Analytics
- **Visualizations:**
  - Animated 7-day bar chart for urge intensities.
  - Frequency chips for "Top Triggers".
  - Time-of-day heatmap displaying highly vulnerable hours.
- Focuses exclusively on behavioral trends, helping the user predict future urges.

### 3.7 Tools & Interventions
Houses the "Intervention Toolkit":
- **90-Second Reset:** Guided breathing session.
- **4-4-4 Breathing:** Animated breathing circle guide.
- **The Vault:** Letters from the user's past self.
- **Write to Future You:** Tool to create future nudges.

### 3.8 Profile & Settings
- **Stats:** Lifetime metrics (Check-ins, overall stability).
- **Toggles:** Biometrics (FaceID/Fingerprint), daily reminders, push notifications configuration.

## 4. Notifications & Intelligence Layer (The Engine)
Stira relies on a sophisticated, purely local notification intelligence system.

### 4.1 Underlying Technology
- `flutter_local_notifications` + `timezone` for scheduled push messaging.
- `workmanager` for background engine execution (runs every 15 minutes).
- `hive` & `hive_flutter` for local NoSQL storage.

### 4.2 Intelligence Engine (`StiraBehaviourAnalyser`)
Analyzes local Hive data every 15 minutes to calculate:
- **Urge Velocity:** Detects rising check-in frequencies.
- **Peak Vulnerability Window:** Predicts the most dangerous hour of the day based on historical averages.
- **Stability Trend:** Week-over-week performance tracking.
- Determines *when* to send interventions proactively without user input.

### 4.3 Notification Throttle Manager
Prevents alert fatigue:
- Limits non-crisis notifications to 2/day.
- Enforces a minimum 3-hour gap between alerts.
- Configurable quiet hours (e.g., 10 PM to 8 AM).
- Triggers a "Rest Mode" auto-pause if notifications are ignored consecutively.

### 4.4 Permissions Required
- **Android:**
  - `POST_NOTIFICATIONS`, `SCHEDULE_EXACT_ALARM`, `USE_BIOMETRIC`, `PACKAGE_USAGE_STATS`, `RECEIVE_BOOT_COMPLETED`
  - `VIBRATE` (For silent SOS haptic feedback)
- **Info.plist:**
  - Background Modes: `fetch`, `processing`

## 5. Outputs & Interactions
- **Visual Notifications:** Timely intelligent reminders triggered strictly based on data thresholds mapped dynamically.
- **Haptic SOS:** Quiet vibrations configured via the Vibration plugin acting as stealth lifelines during high-stress peaks.

## 6. Implementation Guide
1. **Core Utilities Setup:** Initialize Hive for local state and Workmanager for background jobs.
2. **Design Tokens:** Build `stira_theme.dart`. Enforce strict adherence; no hard-coded colors.
3. **Core Reusable UI:** Implement `GlassCard` and `LedMetric`. These are the foundational building blocks for every screen.
4. **App Screens:** Splash -> Auth -> Dashboard -> Check-In -> Insights -> Tools -> Profile. Prioritize UI animations and transition effects.
5. **Background Processes:**
    - Implement `StiraIntelligenceEngine` using `Workmanager` for periodic 15-minute background checks.

This document serves as the master blueprint for the Stira mobile application architecture, aesthetics, logic, and user flows.
