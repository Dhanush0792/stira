import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'theme/stira_tokens.dart';
import 'services/local_storage.dart';
import 'services/widget_service.dart';
import 'services/cloud_sync_service.dart';
import 'services/auth_service.dart';
import 'services/stira_intelligence_engine.dart';
import 'core/intelligence_layer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'firebase_options.dart';
import 'core/auth_wrapper.dart';
import 'package:workmanager/workmanager.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'services/stira_local_notification_service.dart';
import 'services/stira_bond_guardian.dart';

// ─── App Entry Point ────────────────────────────────────────────────────────

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase init - wrapped so app still runs if config missing
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase init failed (non-fatal): $e');
  }

  // Hive - Essential for on-device intelligence
  await Hive.initFlutter();
  await Hive.openBox('check_ins');
  await Hive.openBox('user_data');
  await Hive.openBox('notification_state');
  await Hive.openBox('dopamine_journal');
  await Hive.openBox('commitments');
  await Hive.openBox('notification_taps');
  
  // Initialize services
  Workmanager().initialize(callbackDispatcher, isInDebugMode: false);
  await StiraNotificationService.initialize();
  await StiraNotificationService.requestPermission();
  await StiraIntelligenceEngine.startBackgroundCycle();
  StiraIntelligenceEngine.reactToAction(UserAction.appOpened);

  // Legacy migration check
  await StorageService.migrateIfNeeded();
  await WidgetService.initialize();

  // ── Phase 14: Stabilisation & Guardians ──────────────────────────────────
  StiraBondGuardian().start();

  runApp(const ProviderScope(child: StiraApp()));
}

class StiraApp extends StatefulWidget {
  const StiraApp({super.key});

  @override
  State<StiraApp> createState() => _StiraAppState();
}

class _StiraAppState extends State<StiraApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      StiraIntelligenceEngine.reactToAction(UserAction.appOpened);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stira',
      debugShowCheckedModeBanner: false,
      theme: StiraTokens.theme,
      home: const AuthWrapper(),
    );
  }
}
