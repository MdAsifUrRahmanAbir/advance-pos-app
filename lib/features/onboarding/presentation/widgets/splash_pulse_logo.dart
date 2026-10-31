import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_sizes.dart';
import 'splash_logo.dart';
import 'splash_style.dart';

// FLAG: pulse timings and ring geometry have no tokens.
const Duration _pulseDuration = Duration(milliseconds: 2000);
const double _ringMaxScale = 1.6;
const double _ringWidth = 2;
const List<double> _ringPhases = [0, 0.5];

/// [SplashLogo] with two expanding, fading rings behind it.
/// Rings overflow the layout box (no extra space is reserved) and stop
/// when the system "reduce motion" setting is on.
class SplashPulseLogo extends ConsumerStatefulWidget {
  const SplashPulseLogo({super.key});

  @override
  ConsumerState<SplashPulseLogo> createState() => _SplashPulseLogoState();
}

class _SplashPulseLogoState extends ConsumerState<SplashPulseLogo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: _pulseDuration);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.stop();
      _controller.value = 0;
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const size = AppSizes.xxl + AppSizes.xl;
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        for (final phase in _ringPhases)
          AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              final t = (_controller.value + phase) % 1;
              return Opacity(
                opacity: (1 - t) * SplashStyle.glassAlpha * 2,
                child: Transform.scale(
                  scale: 1 + (_ringMaxScale - 1) * t,
                  child: Container(
                    width: size,
                    height: size,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                      border: Border.all(
                        color: SplashStyle.onPrimary,
                        width: _ringWidth,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        const SplashLogo(size: size),
      ],
    );
  }
}