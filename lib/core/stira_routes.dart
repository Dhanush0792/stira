import 'package:flutter/material.dart';

/// Custom page route: slide (right-to-left) + fade, 280ms, easeOutCubic
/// Use this for ALL push routes in Stira.
class StiraSlideUpRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  StiraSlideUpRoute({required this.page})
      : super(
          transitionDuration: const Duration(milliseconds: 280),
          reverseTransitionDuration: const Duration(milliseconds: 280),
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final curved = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
              reverseCurve: Curves.easeInCubic,
            );
            return FadeTransition(
              opacity: curved,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(1, 0),
                  end: Offset.zero,
                ).animate(curved),
                child: child,
              ),
            );
          },
        );
}

/// Helper extension to push a screen with the Stira slide transition.
extension StiraNavigation on NavigatorState {
  Future<T?> pushStira<T>(Widget page) {
    return push<T>(StiraSlideUpRoute<T>(page: page));
  }

  Future<T?> pushReplacementStira<T, TO>(Widget page) {
    return pushReplacement<T, TO>(StiraSlideUpRoute<T>(page: page) as Route<T>);
  }
}

Future<T?> showStiraModal<T>({
  required BuildContext context,
  required WidgetBuilder builder,
}) {
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Dismiss',
    barrierColor: Colors.black.withOpacity(0.5),
    transitionDuration: const Duration(milliseconds: 350),
    pageBuilder: (context, anim1, anim2) => Align(
      alignment: Alignment.bottomCenter,
      child: Material(
        type: MaterialType.transparency,
        child: builder(context),
      ),
    ),
    transitionBuilder: (context, anim, secondaryAnim, child) {
      final curved = CurvedAnimation(parent: anim, curve: Curves.easeOutCubic, reverseCurve: Curves.easeInCubic);
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero).animate(curved),
          child: child,
        ),
      );
    },
  );
}
