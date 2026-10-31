import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../controllers/splash_controller.dart';
import 'splash_style.dart';

// FLAG: bar height, width factor and status thresholds have no tokens.
const double _barHeight = 6;
const double _barWidthFactor = 0.6;
const double _syncAt = 0.4;
const double _readyAt = 0.8;
const Duration _textFade = Duration(milliseconds: 250);

/// Progress bar that fills over [splashMinDisplay] with rotating status text.
class SplashLoadingIndicator extends ConsumerStatefulWidget {
  const SplashLoadingIndicator({super.key});

  @override
  ConsumerState<SplashLoadingIndicator> createState() =>
      _SplashLoadingIndicatorState();
}

class _SplashLoadingIndicatorState extends ConsumerState<SplashLoadingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _progress;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: splashMinDisplay);
    _progress = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.value = 1;
    } else if (!_controller.isAnimating && _controller.value == 0) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _statusFor(double t) {
    if (t < _syncAt) return AppStrings.splashStatusSecure;
    if (t < _readyAt) return AppStrings.splashStatusSync;
    return AppStrings.splashStatusReady;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _progress,
      builder: (context, _) {
        final status = _statusFor(_controller.value);
        return Column(
          children: [
            FractionallySizedBox(
              widthFactor: _barWidthFactor,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                child: LinearProgressIndicator(
                  value: _progress.value,
                  minHeight: _barHeight,
                  color: SplashStyle.onPrimary,
                  backgroundColor: SplashStyle.onPrimary.withValues(
                    alpha: SplashStyle.glassAlpha,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSizes.md),
            AnimatedSwitcher(
              duration: _textFade,
              child: Text(
                status,
                key: ValueKey(status),
                style: TextStyle(
                  fontSize: AppSizes.fontSm,
                  color: SplashStyle.onPrimary.withValues(
                    alpha: SplashStyle.softTextAlpha,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}