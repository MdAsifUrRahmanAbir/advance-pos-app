import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

extension WidgetAnimationExtension on Widget {
  Widget fadeSlideIn({
    Duration delay = Duration.zero,
    Duration duration = const Duration(milliseconds: 350),
    double slideFrom = 0.08,
    Curve curve = Curves.easeOutCubic,
  }) {
    return animate(delay: delay)
        .fadeIn(duration: duration, curve: curve)
        .slideY(begin: slideFrom, end: 0, duration: duration, curve: curve);
  }

  /// Plain fade only — for content where a slide would feel like too
  /// much (e.g. large hero images, full-screen bodies).
  Widget fadeIn({
    Duration delay = Duration.zero,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return animate(delay: delay).fadeIn(duration: duration);
  }

  /// Subtle scale-in — good for buttons, badges, small icon tiles that
  /// should feel like they "pop" rather than slide.
  Widget scaleIn({
    Duration delay = Duration.zero,
    Duration duration = const Duration(milliseconds: 300),
    double from = 0.92,
  }) {
    return animate(delay: delay)
        .fadeIn(duration: duration)
        .scale(
          begin: Offset(from, from),
          end: const Offset(1, 1),
          duration: duration,
          curve: Curves.easeOutBack,
        );
  }
}
