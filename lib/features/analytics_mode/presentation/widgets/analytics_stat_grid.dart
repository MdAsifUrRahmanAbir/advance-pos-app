import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/common/summary_card.dart';
import '../../../../core/widgets/utility/mini_sparkline.dart';

/// 2x2 grid of Revenue / Expenses / Net Profit / Orders stat cards.
/// Revenue and Expenses include a trailing sparkline; Net Profit and
/// Orders don't (matches the source design).
class AnalyticsStatGrid extends StatelessWidget {
  const AnalyticsStatGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: SummaryCard(
                label: AppStrings.revenueLabel,
                value: '\$48,250',
                trendLabel: '+12.5%',
                isPositiveTrend: true,
                trailing: Flexible(child: const MiniSparkline(values: [20, 35, 25, 45, 60], color: AppColors.success)),
              ),
            ),
            const SizedBox(width: AppSizes.sm + AppSizes.xs),
            Expanded(
              child: SummaryCard(
                label: AppStrings.expensesLabel,
                value: '\$31,800',
                trendLabel: '-3.2%', 
                isPositiveTrend: false,
                trailing: Flexible(child: const MiniSparkline(values: [60, 55, 50, 35, 20], color: AppColors.error)),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.sm + AppSizes.xs),
        Row(
          children: [
            const Expanded(
              child: SummaryCard(
                label: AppStrings.netProfitLabel,
                value: '\$16,450',
                trendLabel: '+18.7%',
                isPositiveTrend: true,
              ),
            ),
            const SizedBox(width: AppSizes.sm + AppSizes.xs),
            const Expanded(
              child: SummaryCard(
                label: AppStrings.ordersLabel2,
                value: '1,284',
                trendLabel: '+5.1%',
                isPositiveTrend: true,
              ),
            ),
          ],
        ),
      ],
    );
  }
}