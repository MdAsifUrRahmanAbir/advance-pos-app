import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/widgets/common/custom_card.dart';
import '../../../../core/widgets/common/status_badge.dart';
import '../states/home_state.dart';

/// Single KPI tile (icon chip + optional trend badge + label + value).
///
/// Built from [CustomCard] + [StatusBadge] rather than a new core widget.
/// If `SummaryCard` already supports icon/trend/label/value, prefer that —
/// this exists as a safe fallback since its exact API wasn't available.
class DashboardStatCard extends StatelessWidget {
  final StatCardData data;

  const DashboardStatCard({super.key, required this.data});

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
              Container(
                padding: const EdgeInsets.all(AppSizes.xs),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                ),
                child: Icon(
                  data.icon,
                  size: AppSizes.iconSm,
                  color: AppColors.primary,
                ),
              ),
              if (data.trendLabel != null)
                StatusBadge(
                  text: data.trendLabel!,
                  type: data.isPositiveTrend
                      ? StatusBadgeType.success
                      : StatusBadgeType.error,
                  compact: true,
                ),
            ],
          ),
          const SizedBox(height: AppSizes.sm),
          Text(
            data.label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: AppSizes.fontSm,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            data.value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: AppSizes.fontLg,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
