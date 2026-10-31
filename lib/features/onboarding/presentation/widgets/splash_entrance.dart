import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_sizes.dart';

// FLAG: animation timings and start scale have no tokens; named private constants.
const Duration _stagger = Duration(milliseconds: 250);
const Duration _duration = Duration(milliseconds: 600);
const double _startScale = 0.85;

/// Fade + slide-up + subtle scale entrance. [step] staggers siblings
/// (step 0 plays first, step 1 after one stagger, and so on).
/// Respects the system "reduce motion" setting.
class SplashEntrance extends ConsumerStatefulWidget {
  final Widget child;
  final int step;
  final Curve curve;

  const SplashEntrance({
    super.key,
    required this.child,
    this.step = 0,
    this.curve = Curves.easeOutCubic,
  });

  @override
  ConsumerState<SplashEntrance> createState() => _SplashEntranceState();
}

class _SplashEntranceState extends ConsumerState<SplashEntrance>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _progress;

  @override
  void initState() {
    super.initState();
    final delay = _stagger * widget.step;
    final total = delay + _duration;
    _controller = AnimationController(vsync: this, duration: total);
    _progress = CurvedAnimation(
      parent: _controller,
      curve: Interval(
        delay.inMilliseconds / total.inMilliseconds,
        1,
        curve: widget.curve,
      ),
    );
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

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _progress,
      child: widget.child,
      builder: (context, child) {
        final t = _progress.value;
        return Opacity(
          opacity: t.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, (1 - t) * AppSizes.lg),
            child: Transform.scale(
              scale: _startScale + (1 - _startScale) * t,
              child: child,
            ),
          ),
        );
      },
    );
  }
}