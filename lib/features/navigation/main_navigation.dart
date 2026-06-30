import 'package:flutter/material.dart';
import '../../theme/stira_tokens.dart';
import '../../widgets/stira_bottom_nav.dart';
import './tabs/home_tab.dart';
import './tabs/insights_tab.dart';
import './tabs/tools_tab.dart';
import './tabs/profile_tab.dart';
import '../../services/stira_auth_service.dart';
import '../../services/stira_local_notification_service.dart';
import '../../services/local_storage.dart';
import '../../services/auth_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/intelligence_layer.dart';
import '../../core/tour/stira_tour_controller.dart';
import '../../services/cloud_sync_service.dart';
import '../../core/tour/stira_tour_overlay.dart';
import 'dart:async';


class MainNavigation extends ConsumerStatefulWidget {
  const MainNavigation({super.key});

  @override
  ConsumerState<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends ConsumerState<MainNavigation> with WidgetsBindingObserver {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    _initAsync();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final shouldShow = await ref.read(tourControllerProvider).shouldShowTour();
      if (shouldShow && mounted) {
        ref.read(tourControllerProvider).startTour();
      }
    });
  }

  Future<void> _initAsync() async {
    final user = ref.read(authServiceProvider).currentUser;
    if (user != null) {
      StiraNotificationService.registerFcmToken();
      // Restore from cloud in background to speed up app entry
      await ref.read(cloudSyncProvider).restoreFromCloud();
    }
    await StiraNotificationService.syncPermissionToStorage();
    await ref.read(intelligenceProvider.notifier).recompute();
  }

  void _handleDeepLink(String payload) {
     debugPrint('FCM: Handling deep link -> \$payload');
     if (payload == 'insights') {
       setState(() => _currentIndex = 1);
     } else if (payload == 'tools') {
       setState(() => _currentIndex = 2);
     } else if (payload == 'profile') {
       setState(() => _currentIndex = 3);
     } else {
       setState(() => _currentIndex = 0);
     }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      debugPrint('MainNavigation: App resumed, triggering intelligence recompute.');
      ref.read(intelligenceProvider.notifier).recompute();
    }
  }

  final List<Widget> _pages = const [
    RepaintBoundary(child: HomeTab()),
    RepaintBoundary(child: InsightsTab()),
    RepaintBoundary(child: ToolsTab()),
    RepaintBoundary(child: ProfileTab()),
  ];

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: StiraTokens.stiraBg,
          body: FadeIndexedStack(
            duration: const Duration(milliseconds: 200),
            index: _currentIndex,
            children: _pages,
          ),
          bottomNavigationBar: StiraBottomNav(
            currentIndex: _currentIndex,
            onTap: (index) => setState(() => _currentIndex = index),
          ),
        ),
        Consumer(
          builder: (context, ref, child) {
            final controller = ref.watch(tourControllerProvider);
            if (controller.isVisible || controller.isCompleted) {
              return StiraTourOverlay();
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }
}

class FadeIndexedStack extends StatefulWidget {
  final int index;
  final List<Widget> children;
  final Duration duration;

  const FadeIndexedStack({
    super.key,
    required this.index,
    required this.children,
    this.duration = const Duration(milliseconds: 250),
  });

  @override
  State<FadeIndexedStack> createState() => _FadeIndexedStackState();
}

class _FadeIndexedStackState extends State<FadeIndexedStack>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: widget.duration);
    _ctrl.forward();
  }

  @override
  void didUpdateWidget(FadeIndexedStack oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.index != oldWidget.index) {
      _ctrl.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: CurvedAnimation(parent: _ctrl, curve: Curves.easeInOutCubic),
      child: IndexedStack(
        index: widget.index,
        children: widget.children,
      ),
    );
  }
}

