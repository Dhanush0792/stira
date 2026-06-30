import 'package:home_widget/home_widget.dart';
import 'behavior_service.dart';
import 'package:flutter/foundation.dart';

class WidgetService {
  static const String _groupId = 'group.com.stira.app'; // match iOS AppGroup
  static const String _iosName = 'StiraWidget';
  static const String _androidName = 'StiraWidgetProvider';

  /// Initializes the widget connection
  static Future<void> initialize() async {
    try {
      await HomeWidget.setAppGroupId(_groupId);
    } catch (e) {
      debugPrint('Error initializing HomeWidget: $e');
    }
  }

  /// Sends the appropriate mantra to the home screen widget based on RiskLevel
  static Future<void> updateWidgetForForecast(ForecastResult forecast) async {
    try {
      String mantra = "The baseline is steady.";

      // We only have ForecastResult, but risk Level might not be in it directly.
      // Wait, let's just make it simple. If subtitle implies high risk, change it.
      if (forecast.subtitle.contains('exhaustion')) {
        mantra = "Rest is required for resilience.";
      } else {
        mantra = "The baseline is steady. Urges are objects.";
      }

      await HomeWidget.saveWidgetData<String>('stira_mantra', mantra);
      
      // Tell native side to refresh
      await HomeWidget.updateWidget(
        name: _androidName,
        iOSName: _iosName,
      );
    } catch (e) {
      debugPrint('Error updating widget: $e');
    }
  }
}
