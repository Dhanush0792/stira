import 'package:flutter/material.dart';

enum TourAnchor {
  center,
  topCenter,
  bottomCenter,
  bottomLeft,
  bottomRight,
}

class StiraTourStep {
  final String id;
  final String title;
  final String description;
  final String accentColor;
  final TourAnchor anchor;
  final String? highlightTarget;

  const StiraTourStep({
    required this.id,
    required this.title,
    required this.description,
    required this.accentColor,
    required this.anchor,
    this.highlightTarget,
  });
}

class StiraFeatureInfo {
  final String featureId;
  final String title;
  final String subtitle;
  final String body;
  final String accentColor;
  final String? tip;

  const StiraFeatureInfo({
    required this.featureId,
    required this.title,
    required this.subtitle,
    required this.body,
    required this.accentColor,
    this.tip,
  });
}

class StiraTourData {
  static const List<StiraTourStep> steps = [
    StiraTourStep(
      id: "welcome",
      title: "Welcome to Stira.",
      description: "Stira is your private behavioral intelligence companion. It learns your patterns, predicts your vulnerable moments, and gives you the right tool before the urge peaks — not after. Everything stays on your device.",
      accentColor: "pink",
      anchor: TourAnchor.center,
    ),
    StiraTourStep(
      id: "orb",
      title: "Your Stability Orb.",
      description: "The orb in the center of your dashboard is a live reflection of your current state. Its color and pulse shift based on your recent check-ins. Pink means elevated risk. Teal means stability. Tap it anytime to start a check-in.",
      accentColor: "pink",
      anchor: TourAnchor.topCenter,
    ),
    StiraTourStep(
      id: "streak",
      title: "Your Active Streak.",
      description: "Every clean day adds to your streak. This number is not just a count — it feeds Stira's prediction engine. The longer your streak, the more accurately Stira can forecast your vulnerable windows and protect your progress.",
      accentColor: "pink",
      anchor: TourAnchor.topCenter,
    ),
    StiraTourStep(
      id: "stability_score",
      title: "Stability Score.",
      description: "Your Stability Score (0 to 100) is calculated from your check-in history, urge intensity trends, and recovery momentum. A rising score means your patterns are improving week over week. Check the Insights tab to see what is driving it.",
      accentColor: "teal",
      anchor: TourAnchor.topCenter,
    ),
    StiraTourStep(
      id: "forecast",
      title: "Your Forecast.",
      description: "Stira analyses your past check-ins to predict when your next high-risk window is coming — usually 30 to 45 minutes before it arrives. The amber forecast card on your dashboard shows your risk level for the next few hours. Act before the urge, not during it.",
      accentColor: "amber",
      anchor: TourAnchor.bottomCenter,
    ),
    StiraTourStep(
      id: "checkin",
      title: "Daily Check-In.",
      description: "Tap Check-In to log your current urge intensity using the radial dial. Select what triggered you and where you are. This 30-second habit is what makes every other Stira feature smarter — the more you log, the more accurate your forecast becomes.",
      accentColor: "pink",
      anchor: TourAnchor.bottomCenter,
    ),
    StiraTourStep(
      id: "tools",
      title: "Your Intervention Tools.",
      description: "The Tools tab holds your crisis toolkit: 90-second breathing reset, 4-4-4 guided breathing, The Vault (letters from your stronger self), and Replacement Habits. These are designed to interrupt the autopilot loop within 90 seconds. Use them the moment you feel an urge rising.",
      accentColor: "teal",
      anchor: TourAnchor.bottomCenter,
    ),
    StiraTourStep(
      id: "insights",
      title: "Behavioural Insights.",
      description: "The Insights tab turns your check-in data into visual patterns — a 7-day urge intensity chart, your most vulnerable hours of the day, and your top triggers by frequency. Understanding your pattern is the first step to changing it.",
      accentColor: "violet",
      anchor: TourAnchor.bottomCenter,
    ),

    StiraTourStep(
      id: "notifications",
      title: "Intelligent Notifications.",
      description: "Stira sends at most 2 notifications per day, timed precisely to your predicted vulnerable window. They are never random. Every alert is based on your actual data — your patterns, your history, your timing. Enable them in Profile to activate the full intelligence engine.",
      accentColor: "teal",
      anchor: TourAnchor.center,
    ),
  ];

  static const Map<String, StiraFeatureInfo> featureInfoMap = {
    "orb": StiraFeatureInfo(
      featureId: "orb",
      title: "The Stability Orb",
      subtitle: "A live reflection of your current behavioral state.",
      body: "The orb reads your most recent check-in data and changes color and pulse intensity based on your current risk level. Pink and fast means your urge intensity is elevated. Teal and slow means you are in a stable window. The orb never lies — it only reflects what you have told Stira through your check-ins. Tap it directly to open a check-in from anywhere on the dashboard.",
      accentColor: "pink",
      tip: "Tip: The orb is most accurate after 7 days of consistent check-ins.",
    ),
    "streak": StiraFeatureInfo(
      featureId: "streak",
      title: "Active Streak",
      subtitle: "Every clean day counts toward your longest run.",
      body: "Your streak counts consecutive days without a relapse. It resets if you log a Reset, but your total clean days are never lost — they are stored permanently and visible in your profile. A streak is not just a number. It is the primary input to Stira's forecast engine. Longer streaks teach the system more about your stable patterns, making predictions more accurate over time. Tap the streak to see your trajectory graph.",
      accentColor: "pink",
      tip: "Tip: Use Streak Insurance (unlocked at Day 14) to protect one milestone from being lost.",
    ),
    "stability_score": StiraFeatureInfo(
      featureId: "stability_score",
      title: "Stability Score",
      subtitle: "Your behavioral health score from 0 to 100.",
      body: "The Stability Score is a composite metric calculated from your check-in consistency, average urge intensity over the past 7 days, and your week-over-week recovery trend. A score above 70 means your patterns are strong. Below 40 means the system has detected escalating risk and will increase its alerting frequency. The score updates every time you submit a check-in. It is private, stored only on your device, and never shared.",
      accentColor: "teal",
      tip: "Tip: Logging a check-in even on a hard day improves your score more than skipping it.",
    ),
    "forecast": StiraFeatureInfo(
      featureId: "forecast",
      title: "Forecast Engine",
      subtitle: "Predicts your next high-risk window before it arrives.",
      body: "After 7 days of check-ins, Stira builds a personal vulnerability curve based on when and how intensely you have historically felt urges. The forecast card on your dashboard shows the predicted risk level for the next 4 to 6 hours — low, moderate, or elevated. A notification fires 30 to 45 minutes before your calculated peak window so you can prepare a tool in advance. The forecast accuracy score appears in Insights after 14 days of data.",
      accentColor: "amber",
      tip: "Tip: The more consistently you check in, the more accurate the forecast becomes. Three days of data gives you a basic forecast. Seven days gives you a reliable one.",
    ),
    "checkin": StiraFeatureInfo(
      featureId: "checkin",
      title: "Daily Check-In",
      subtitle: "The 30-second habit that powers everything else.",
      body: "A check-in captures your current urge intensity on a radial dial from 1 to 10, the trigger behind it (Boredom, Stress, Loneliness, Habit, Fatigue, or Social Media), your location, and your energy level. This data is stored locally on your device and feeds directly into the forecast engine, the stability score, and the notification intelligence system. The more honestly you check in, the smarter Stira becomes. A check-in takes 30 seconds and changes the accuracy of everything that follows.",
      accentColor: "pink",
      tip: "Tip: Check in even when the intensity is low. Low data points are just as important as high ones for building your pattern.",
    ),
    "breathing_reset": StiraFeatureInfo(
      featureId: "breathing_reset",
      title: "90-Second Reset",
      subtitle: "A guided breathing session to interrupt autopilot in 90 seconds.",
      body: "The 90-Second Reset is Stira's fastest intervention tool. It opens a full-screen breathing guide with an animated circle that expands and contracts across three phases: inhale for 4 seconds, hold for 4 seconds, exhale for 4 seconds. The visual cue is designed to override the automatic urge response before it peaks. Research shows that 3 full breath cycles are enough to meaningfully reduce acute stress. This tool is automatically surfaced when your check-in intensity is 7 or higher.",
      accentColor: "teal",
      tip: "Tip: Follow the circle visually, not just the timer. The animation is calibrated to the correct pace.",
    ),
    "vault": StiraFeatureInfo(
      featureId: "vault",
      title: "The Vault",
      subtitle: "Letters from your stronger self, opened when you need them most.",
      body: "The Vault stores letters you write to yourself during calm, strong moments. You choose what you want your future self to remember when things get difficult. When your check-in intensity reaches 8 or higher, Stira automatically opens the most recent Vault letter before showing any other tool. Reading your own words from a place of strength is one of the most effective pattern interrupts in behavioral recovery. Write a letter before you need it.",
      accentColor: "amber",
      tip: "Tip: Write at least one letter in the first week. Tag it with your emotional state so Stira can surface the most relevant one.",
    ),
    "insights_chart": StiraFeatureInfo(
      featureId: "insights_chart",
      title: "Urge Intensity Chart",
      subtitle: "7 days of your behavioral data in one view.",
      body: "The bar chart in your Insights tab shows your daily average urge intensity across the last 7 days. Teal bars are stable days. Amber bars are moderate. Pink bars are elevated. The pattern across the week tells you more than any single number — it shows whether your trajectory is improving, holding, or deteriorating. Combined with the heatmap, you will quickly see which days and hours are consistently hardest for you.",
      accentColor: "violet",
      tip: "Tip: Look for the pattern across days, not just yesterday's bar. A downward trend across 5 days is more meaningful than one bad day.",
    ),
    "insights_heatmap": StiraFeatureInfo(
      featureId: "insights_heatmap",
      title: "Vulnerability Heatmap",
      subtitle: "Which hours of the day are hardest for you.",
      body: "The heatmap shows a 24-hour grid of your urge intensity data, averaged across all your check-ins. Bright cells mean that time of day is consistently high-risk for you. Dark cells are your stable hours. This is the single most useful piece of data Stira produces — knowing your high-risk hour means you can plan around it rather than be caught off guard by it. The forecast engine uses this heatmap to calculate the timing of your vulnerability warning notifications.",
      accentColor: "violet",
      tip: "Tip: Plan something active or social during your brightest heatmap hours. Replacing the pattern is more effective than resisting it.",
    ),
    "top_triggers": StiraFeatureInfo(
      featureId: "top_triggers",
      title: "Top Triggers",
      subtitle: "The emotions and situations that most often precede your urges.",
      body: "Top Triggers shows the percentage breakdown of which triggers you have selected most often across all your check-ins. Your number-one trigger is the single most important thing to understand about your behavioral pattern. Once you know your primary trigger, you can use the Replacement Habit Engine in the Tools tab to find a habit that meets the same underlying need without the damage. Triggers are color-coded so you can track them across the chart and heatmap simultaneously.",
      accentColor: "violet",
      tip: "Tip: The trigger you select least often is often the most honest one. Social Media and Loneliness are frequently underreported.",
    ),

    "replacement_habits": StiraFeatureInfo(
      featureId: "replacement_habits",
      title: "Replacement Habit Engine",
      subtitle: "Every urge hides a real need. This finds what you actually need.",
      body: "The Replacement Habit Engine maps your core need — Stimulation, Calm, Connection, Escape, or Achievement — and suggests a habit that satisfies the same need without the damage. When you feel an urge and your check-in intensity is 5 or higher, the engine surfaces the top habit that matches your need based on your onboarding answers and your check-in trigger history. You can also build a custom habit library with your own names and categories. The engine tracks which habits you complete and shows your success rate per habit in the Insights tab over time.",
      accentColor: "teal",
      tip: "Tip: Cold shower and 10 pushups are the highest-success habits across all users for Stimulation needs. They work because they provide immediate physical intensity.",
    ),
    "identity_builder": StiraFeatureInfo(
      featureId: "identity_builder",
      title: "Identity Builder",
      subtitle: "Recovery is about becoming someone who does not need it.",
      body: "The Identity Builder holds the three identity statements you wrote during onboarding — who you are becoming, not who you are fighting against. Each streak milestone unlocks a new affirmation card that reflects your progress. A daily identity push notification fires at your predicted vulnerable window with a rotating completion prompt: I am someone who... Over time, these statements shift from aspiration to description. The most effective long-term recovery is identity-based, not willpower-based.",
      accentColor: "violet",
      tip: "Tip: Edit your identity statements as you grow. The ones you wrote at Day 1 should feel small by Day 90.",
    ),
    "bond_mode": StiraFeatureInfo(
      featureId: "bond_mode",
      title: "Bond Mode",
      subtitle: "One trusted person. Complete privacy. No surveillance.",
      body: "Bond Mode connects you with exactly one person of your choice — a friend, partner, or sibling — using a private 6-digit code. Your Bond partner sees only what you choose to share: streak only, streak and intensity, or full insights. When your urge intensity reaches 7 or higher, your Bond partner receives a single notification: your person might need you right now. They can send a pre-written encouragement or a custom message. There is no screen monitoring, no browsing history access, and no community. It is private accountability between two people who trust each other.",
      accentColor: "teal",
      tip: "Tip: Choose a Bond partner before you need one. Setting up the connection during a stable moment means it is ready when a crisis comes.",
    ),
    "weekly_report": StiraFeatureInfo(
      featureId: "weekly_report",
      title: "Weekly Stability Report",
      subtitle: "A personal narrative digest of your week, written by AI.",
      body: "Every Sunday morning, Stira generates a short narrative summary of your week — your most stable day, your most vulnerable day, your top trigger, and one specific focus for the coming week. It is written in warm human language, not a table of numbers. The report is generated entirely on your device using your local check-in data and the Claude AI model. It is private, never sent anywhere, and never stored outside your device. You can share an anonymous version with your Bond partner if you choose.",
      accentColor: "violet",
      tip: "Tip: Read the report on Sunday morning before the week begins. The one-focus recommendation is the most actionable part.",
    ),
    "notifications_settings": StiraFeatureInfo(
      featureId: "notifications_settings",
      title: "Notification Intelligence",
      subtitle: "At most 2 notifications per day, timed to your actual pattern.",
      body: "Stira's notification system does not use Firebase or any server. Every alert is scheduled entirely on your device based on your local check-in data. The system fires at most 2 notifications per day and enforces a 3-hour minimum gap between any two alerts. Quiet hours (10 PM to 8 AM) prevent night-time disruption. Notifications are sent only when the data justifies them — not on a fixed schedule. The intelligence engine calculates your peak vulnerability window from your check-in history and fires the warning 30 to 45 minutes before it arrives.",
      accentColor: "teal",
      tip: "Tip: Enable notifications even if you plan to ignore most of them. The system enters Rest Mode automatically if you ignore 5 consecutive alerts and reduces frequency on its own.",
    ),
    "streak_insurance": StiraFeatureInfo(
      featureId: "streak_insurance",
      title: "Streak Insurance",
      subtitle: "Protect one milestone from being lost to a single slip.",
      body: "Streak Insurance is unlocked at Day 14, Day 30, and Day 60. When you log a relapse, a special screen appears before your streak resets — you can choose to use one insurance to keep the streak counter intact. The relapse is still logged in full, still feeds the AI engine, and is still visible in your Insights. The streak counter simply does not reset. Streak Insurance is not forgiveness. It is resilience. Research shows that the biggest risk to long-term recovery is abandoning the app after a streak loss — this feature exists to prevent that.",
      accentColor: "amber",
      tip: "Tip: Do not save Streak Insurance for later. Use it the first time you need it. You earn another one at the next milestone.",
    ),
    "shadow_mode": StiraFeatureInfo(
      featureId: "shadow_mode",
      title: "Shadow Mode",
      subtitle: "Disguise Stira as a different app on your home screen.",
      body: "Shadow Mode changes Stira's home screen icon, app name in the task switcher, and splash screen to look like a completely different app — a Weather App, Calculator, Finance Tracker, Notes App, or Clock. Inside, Stira works completely normally. This feature exists for users who live with family, share devices, or face social stigma around using a recovery app. Privacy without hiding. Activate Shadow Mode in Profile settings and set your unlock gesture — a triple tap on the disguised icon.",
      accentColor: "violet",
      tip: "Tip: Choose a disguise that makes sense on your home screen. A Calculator icon is the most neutral choice.",
    ),
  };
}
