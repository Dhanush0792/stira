import 'package:vibration/vibration.dart';

class StiraHapticService {
  static final StiraHapticService _instance = StiraHapticService._internal();

  factory StiraHapticService() => _instance;

  StiraHapticService._internal();

  /// Trigger conditions: 
  /// (1) Danger Zone radius entered
  /// (2) Check-in intensity ≥ 8 logged
  /// (3) User manually activates from Tools tab.
  /// 
  /// Haptic pattern: 3 short pulses (100ms each) → pause 200ms → 1 long pulse (600ms) → pause 200ms → 3 short pulses.
  Future<void> triggerSOSHeartbeat() async {
    bool? hasCustomVibrationsSupport = await Vibration.hasCustomVibrationsSupport();
    if (hasCustomVibrationsSupport == true) {
      Vibration.vibrate(
        pattern: [
          0, 100,    // start immediately, pulse 100
          100, 100,  // pause 100, pulse 100
          100, 100,  // pause 100, pulse 100
          200, 600,  // pause 200, pulse 600
          200, 100,  // pause 200, pulse 100
          100, 100,  // pause 100, pulse 100
          100, 100   // pause 100, pulse 100
        ],
      );
    } else {
      // Fallback for devices without custom pattern support
      Vibration.vibrate(duration: 1000); 
    }
  }

  /// Success haptic — short, sharp pulse.
  Future<void> triggerSuccess() async {
    if (await Vibration.hasVibrator() == true) {
      Vibration.vibrate(duration: 50);
    }
  }

  /// Error haptic — double quick pulse.
  Future<void> triggerError() async {
    if (await Vibration.hasVibrator() == true) {
      Vibration.vibrate(pattern: [0, 70, 50, 70]);
    }
  }

  /// Light tick — very subtle feedback.
  Future<void> triggerLightTick() async {
    if (await Vibration.hasVibrator() == true) {
      Vibration.vibrate(duration: 30);
    }
  }
}
