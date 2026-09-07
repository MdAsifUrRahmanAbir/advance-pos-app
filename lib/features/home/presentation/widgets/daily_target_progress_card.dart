import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/common/custom_card.dart';

/// Progress-bar KPI card. Feature-local for now — generic enough
/// (payment progress, leave-balance progress, etc.) to be worth promoting
/// into generate_core_widget.py as a shared `LinearProgressCard` later.
class DailyTargetProgressCard extends StatelessWidget {
  final double percent; // 0.0–1.0
  final String achieved;
  final String goal;

  const DailyTargetProgressCard({
    super.key,
    required this.percent,
    required this.achieved,
    required this.goal,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      padding: const EdgeInsets.all(AppSizes.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppStrings.dailyTargetProgress,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: AppSizes.fontSm,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${(percent * 100).round()}%',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: AppSizes.fontSm,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSizes.radiusFull),
            child: LinearProgressIndicator(
              value: percent.clamp(0, 1),
              minHeight: 8,
              backgroundColor: AppColors.primary.withValues(alpha: 0.15),
              valueColor: AlwaysStoppedAnimation(AppColors.primary),
            ),
          ),
          const SizedBox(height: AppSizes.xs),
          Text(
            AppStrings.dailyTargetSubtitle(achieved, goal),
            style: TextStyle(color: AppColors.textSecondary, fontSize: AppSizes.fontXs),
          ),
        ],
      ),
    );
  }
}