import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../controllers/analytics_mode_controller.dart';
import '../widgets/analytics_header.dart';
import '../widgets/analytics_stat_grid.dart';
import '../widgets/revenue_expense_chart_card.dart';
import '../widgets/category_breakdown_card.dart';

class AnalyticsMobileView extends ConsumerWidget {
  const AnalyticsMobileView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedRange = ref.watch(analyticsControllerProvider).selectedRange;

    return Column(
      children: [
        AnalyticsHeader(
          dateRangeLabel: 'Jan 1, 2026 - Jan 31, 2026',
          onExportTap: () {
            // TODO: open export options once analyticsControllerProvider
            // has real data to export.
          },
          onDateRangeTap: () {
            // TODO: open a date-range picker
          },
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSizes.md),
            child: Column(
              children: [
                // TODO: replace hardcoded chart/category data with
                // analyticsControllerProvider once
                // features/analytics/data/repositories is implemented.
                const AnalyticsStatGrid(),
                const SizedBox(height: AppSizes.lg),
                RevenueExpenseChartCard(
                  selectedRange: selectedRange,
                  onRangeChanged: (r) =>
                      ref.read(analyticsControllerProvider.notifier).selectRange(r),
                  revenueValues: const [45, 62, 40, 95, 55, 105, 88, 130],
                  expenseValues: const [40, 55, 35, 78, 50, 90, 80, 130],
                  yAxisLabels: const ['120k', '80k', '40k', '0k'],
                  xAxisLabels: const ['Week 1', 'Week 2', 'Week 3', 'Week 4'],
                ),
                const SizedBox(height: AppSizes.lg),
                CategoryBreakdownCard(
                  centerLabel: 'SaaS',
                  shares: const [
                    CategoryShare(label: 'SaaS Suite', percent: 60, color: AppColors.primary),
                    CategoryShare(label: 'Infrastructure', percent: 15, color: AppColors.success),
                    CategoryShare(label: 'Hardware', percent: 10, color: AppColors.warning),
                    CategoryShare(label: 'Other', percent: 5, color: AppColors.error),
                    CategoryShare(label: 'My', percent: 10, color: AppColors.shimmerHighlight),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}