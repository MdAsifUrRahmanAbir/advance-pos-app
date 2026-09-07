import 'package:flutter/material.dart';
import 'package:template_test/core/constants/app_colors.dart';
import 'package:template_test/core/constants/app_sizes.dart';

class CustomShimmer extends StatefulWidget {
  final double height;
  final double? width;
  final BorderRadius? borderRadius;

  const CustomShimmer({
    super.key,
    this.height = AppSizes.xxl,
    this.width,
    this.borderRadius,
  });

  @override
  State<CustomShimmer> createState() => _CustomShimmerState();
}

class _CustomShimmerState extends State<CustomShimmer> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1100))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment(-1 + (_controller.value * 2), 0),
            end: Alignment(1 + (_controller.value * 2), 0),
            colors: const [AppColors.shimmerBase, AppColors.shimmerHighlight, AppColors.shimmerBase],
          ),
          borderRadius: widget.borderRadius ?? BorderRadius.circular(AppSizes.radiusMd),
        ),
        child: SizedBox(height: widget.height, width: widget.width ?? double.infinity),
      ),
    );
  }
}
