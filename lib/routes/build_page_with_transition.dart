import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

enum PageTransitionType {
  fade,
  slide,
  slideFromRight,
  slideFromLeft,
  slideFromTop,
  slideFromBottom,
  scale,
  fadeScale,
  rotation,
  fadeSlide,
  fadeSlideFromRight,
}

CustomTransitionPage<T> buildPageWithTransition<T>({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,

  // Default animation
  PageTransitionType animationType =
      PageTransitionType.slideFromRight,
}) {
  return CustomTransitionPage<T>(
    key: state.pageKey,

    child: child,

    transitionDuration: const Duration(
      milliseconds: 300,
    ),

    reverseTransitionDuration: const Duration(
      milliseconds: 300,
    ),

    transitionsBuilder: (
        context,
        animation,
        secondaryAnimation,
        child,
        ) {
      final curvedAnimation = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );

      switch (animationType) {
      // ==================================================
      // FADE
      // Enter: Fade In
      // Back:  Fade Out
      // ==================================================
        case PageTransitionType.fade:
          return FadeTransition(
            opacity: curvedAnimation,
            child: child,
          );

      // ==================================================
      // SMALL SLIDE
      // Enter: Slide In
      // Back:  Slide Out
      // ==================================================
        case PageTransitionType.slide:
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.05, 0.02),
              end: Offset.zero,
            ).animate(curvedAnimation),
            child: child,
          );

      // ==================================================
      // FROM RIGHT
      // Enter: Right -> Center
      // Back:  Center -> Right
      // ==================================================
        case PageTransitionType.slideFromRight:
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1, 0),
              end: Offset.zero,
            ).animate(curvedAnimation),
            child: child,
          );

      // ==================================================
      // FROM LEFT
      // Enter: Left -> Center
      // Back:  Center -> Left
      // ==================================================
        case PageTransitionType.slideFromLeft:
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(-1, 0),
              end: Offset.zero,
            ).animate(curvedAnimation),
            child: child,
          );

      // ==================================================
      // FROM TOP
      // Enter: Top -> Center
      // Back:  Center -> Top
      // ==================================================
        case PageTransitionType.slideFromTop:
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, -1),
              end: Offset.zero,
            ).animate(curvedAnimation),
            child: child,
          );

      // ==================================================
      // FROM BOTTOM
      // Enter: Bottom -> Center
      // Back:  Center -> Bottom
      // ==================================================
        case PageTransitionType.slideFromBottom:
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 1),
              end: Offset.zero,
            ).animate(curvedAnimation),
            child: child,
          );

      // ==================================================
      // SCALE
      // Enter: Small -> Normal
      // Back:  Normal -> Small
      // ==================================================
        case PageTransitionType.scale:
          return ScaleTransition(
            scale: Tween<double>(
              begin: 0.90,
              end: 1.0,
            ).animate(curvedAnimation),
            child: child,
          );

      // ==================================================
      // FADE + SCALE
      // ==================================================
        case PageTransitionType.fadeScale:
          return FadeTransition(
            opacity: curvedAnimation,
            child: ScaleTransition(
              scale: Tween<double>(
                begin: 0.92,
                end: 1.0,
              ).animate(curvedAnimation),
              child: child,
            ),
          );

      // ==================================================
      // ROTATION
      // ==================================================
        case PageTransitionType.rotation:
          return FadeTransition(
            opacity: curvedAnimation,
            child: RotationTransition(
              turns: Tween<double>(
                begin: 0.02,
                end: 0.0,
              ).animate(curvedAnimation),
              child: child,
            ),
          );

      // ==================================================
      // FADE + SMALL SLIDE
      // ==================================================
        case PageTransitionType.fadeSlide:
          return FadeTransition(
            opacity: curvedAnimation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.05, 0.02),
                end: Offset.zero,
              ).animate(curvedAnimation),
              child: child,
            ),
          );

      // ==================================================
      // FADE + RIGHT SLIDE
      // ==================================================
        case PageTransitionType.fadeSlideFromRight:
          return FadeTransition(
            opacity: curvedAnimation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.25, 0),
                end: Offset.zero,
              ).animate(curvedAnimation),
              child: child,
            ),
          );
      }
    },
  );
}