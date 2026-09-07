import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_sizes.dart';

/// Vertical timeline marker — a soft-tinted circle with a solid dot,
/// plus a connecting line below it. Used to the left of each row in
/// timeline-style feeds (activity logs, order tracking).
class TimelineIndicator extends StatelessWidget {
  final Color color;
  final bool showLine;
  final double lineHeight;

  const TimelineIndicator({
    super.key,
    this.color = AppColors.textSecondary,
    this.showLine = true,
    this.lineHeight = AppSizes.xxl * 2,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: AppSizes.lg,
          height: AppSizes.lg,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withValues(alpha: 0.12),
          ),
          alignment: Alignment.center,
          child: Container(
            width: AppSizes.xs + AppSizes.xs / 1.5,
            height: AppSizes.xs + AppSizes.xs / 1.5,
            decoration: BoxDecoration(shape: BoxShape.circle, color: color),
          ),
        ),
        if (showLine)
          Container(
            width: 2,
            height: lineHeight,
            color: AppColors.border,
          ),
      ],
    );
  }
}