import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'stira_tour_data.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final tourControllerProvider = ChangeNotifierProvider((ref) => StiraTourController());

class StiraTourController extends ChangeNotifier {
  bool isVisible = false;
  int currentStepIndex = 0;
  bool isCompleted = false;

  Future<bool> shouldShowTour() async {
    final prefs = Hive.box('stira_prefs');
    final bool tourCompleted = prefs.get('tour_completed', defaultValue: false);
    
    // Also verify onboarding is fully completed
    final bool onboardingCompleted = prefs.get('onboarding_completed', defaultValue: false);

    if (tourCompleted) return false;
    if (!onboardingCompleted) return false;
    
    return true;
  }

  void startTour() {
    isVisible = true;
    currentStepIndex = 0;
    notifyListeners();
  }

  void nextStep() {
    if (currentStepIndex < totalSteps - 1) {
      currentStepIndex++;
      notifyListeners();
    } else {
      completeTour();
    }
  }

  void previousStep() {
    if (currentStepIndex > 0) {
      currentStepIndex--;
      notifyListeners();
    }
  }

  void skipTour() {
    completeTour();
  }

  void completeTour() {
    isVisible = false;
    isCompleted = true;
    final prefs = Hive.box('stira_prefs');
    prefs.put('tour_completed', true);
    notifyListeners();
  }

  void resetTour() {
    isVisible = true;
    currentStepIndex = 0;
    isCompleted = false;
    final prefs = Hive.box('stira_prefs');
    prefs.put('tour_completed', false);
    notifyListeners();
  }

  StiraTourStep get currentStep => StiraTourData.steps[currentStepIndex];

  int get totalSteps => StiraTourData.steps.length;

  double get progress => (currentStepIndex + 1) / totalSteps;
}
