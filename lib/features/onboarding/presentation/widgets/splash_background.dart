import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import 'splash_style.dart';

// FLAG: decorative circle sizes have no tokens.
const double _bigCircle = 320;
const double _smallCircle = 200;

/// Solid primary background with two soft decorative circles.
class SplashBackground extends StatelessWidget {
  final Widget child;

  const SplashBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.primary,
      child: Stack(
        children: [
          Positioned(
            top: -_bigCircle / 3,
            right: -_bigCircle / 3,
            child: const _Circle(size: _bigCircle),
          ),
          Positioned(
            bottom: -_smallCircle / 3,
            left: -_smallCircle / 3,
            child: const _Circle(size: _smallCircle),
          ),
          Positioned.fill(child: child),
        ],
      ),
    );
  }
}

class _Circle extends StatelessWidget {
  final double size;

  const _Circle({required this.size});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: SplashStyle.onPrimary.withValues(alpha: SplashStyle.decorAlpha),
        ),
      ),
    );
  }
}