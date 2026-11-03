import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

import '../../constants/app_sizes.dart';

/// Duration of one flight.
const Duration _flightDuration = Duration(milliseconds: 650);

/// How far above the higher end point the arc peaks — no token, flagged.
const double _arcLift = AppSizes.xxl * 2;

/// Size and opacity of the flying widget when it lands.
const double _endScale = 0.35;
const double _endOpacity = 0.6;

/// Global rect of the widget that owns [context], or null when it is not
/// laid out (e.g. not mounted yet).
Rect? globalRectOf(BuildContext context) {
  final box = context.findRenderObject();
  if (box is! RenderBox || !box.attached || !box.hasSize) return null;
  return box.localToGlobal(Offset.zero) & box.size;
}

/// Flies [child] (a [size]-square widget) in the root overlay from the
/// center of [from] to the center of [to] along an upward arc, shrinking
/// and fading as it lands, then calls [onArrived]. Fire-and-forget: several
/// flights can run at once, and nothing blocks taps meanwhile.
///
/// When the platform asks for reduced motion, or there is no overlay, the
/// flight is skipped and [onArrived] is called straight away.
///
/// Typical use: "add to cart" — fly a product thumbnail from the tapped
/// card to the cart badge, then pulse the badge in [onArrived].
void flyToTarget(
  BuildContext context, {
  required Rect from,
  required Rect to,
  required Widget child,
  double size = AppSizes.xxl,
  Duration duration = _flightDuration,
  VoidCallback? onArrived,
}) {
  final overlay = Overlay.maybeOf(context, rootOverlay: true);
  final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
  final overlayBox = overlay?.context.findRenderObject();
  if (overlay == null || reduceMotion || overlayBox is! RenderBox) {
    onArrived?.call();
    return;
  }

  final start = overlayBox.globalToLocal(from.center);
  final end = overlayBox.globalToLocal(to.center);
  final control = Offset(
    (start.dx + end.dx) / 2,
    (start.dy < end.dy ? start.dy : end.dy) - _arcLift,
  );

  late final OverlayEntry entry;
  entry = OverlayEntry(
    builder: (_) => TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: duration,
      curve: Curves.easeInOutCubic,
      onEnd: () {
        entry.remove();
        onArrived?.call();
      },
      child: SizedBox.square(dimension: size, child: child),
      builder: (_, t, flying) {
        final point = _quadraticBezier(start, control, end, t);
        return Positioned(
          left: point.dx - size / 2,
          top: point.dy - size / 2,
          child: IgnorePointer(
            child: Opacity(
              opacity: lerpDouble(1, _endOpacity, t)!,
              child: Transform.scale(
                scale: lerpDouble(1, _endScale, t)!,
                child: flying,
              ),
            ),
          ),
        );
      },
    ),
  );
  overlay.insert(entry);
}

Offset _quadraticBezier(Offset p0, Offset p1, Offset p2, double t) {
  final u = 1 - t;
  return p0 * (u * u) + p1 * (2 * u * t) + p2 * (t * t);
}
