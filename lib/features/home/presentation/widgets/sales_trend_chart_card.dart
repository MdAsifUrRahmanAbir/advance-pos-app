import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_color_scheme.dart';
import '../../../../core/widgets/common/custom_card.dart';
import '../../../../core/widgets/utility/multi_line_chart.dart';
import '../states/dashboard_format.dart';
import '../states/home_state.dart';
import 'dashboard_metric.dart';
import 'dashboard_segmented_toggle.dart';

/// Sales trend (filled area line) with its own range toggle (7 days /
/// 12 months) and a 2×2 grid of totals underneath.
class SalesTrendChartCard extends StatelessWidget {
  final SalesTrendData data;
  final int selectedIndex;
  final ValueChanged<int> onRangeChanged;

  const SalesTrendChartCard({
    super.key,
    required this.data,
    required this.selectedIndex,
    required this.onRangeChanged,
  });

  /// Chart height — no AppSizes token fits, flagged.
  static const double _chartHeight = 180;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return CustomCard(
      padding: const EdgeInsets.all(AppSizes.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  AppStrings.dashSalesTrend,
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: AppSizes.fontMd,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              DashboardSegmentedToggle(
                labels: const [
                  AppStrings.dashRange7Days,
                  AppStrings.dashRange12Months,
                ],
                selectedIndex: selectedIndex,
                onChanged: onRangeChanged,
              ),
            ],
          ),
          const SizedBox(height: AppSizes.md),
          if (data.hasData)
            Skeleton.leaf(
              child: MultiLineChart(
                series: [
                  ChartSeries(
                    label: AppStrings.dashSales,
                    color: AppColors.primary,
                    values: data.values,
                  ),
                ],
                yAxisLabels: [
                  DashboardFormat.compact(data.maxAmount),
                  DashboardFormat.compact(data.maxAmount / 2),
                  '0',
                ],
                xAxisLabels: data.labels,
                height: _chartHeight,
                fillArea: true,
              ),
            )
          else
            SizedBox(
              height: _chartHeight,
              child: Center(
                child: Text(
                  AppStrings.dashNoData,
                  style: TextStyle(color: colors.textSecondary, fontSize: AppSizes.fontSm),
                ),
              ),
            ),
          const SizedBox(height: AppSizes.md),
          Row(
            children: [
              Expanded(
                child: _StatTile(
                  label: AppStrings.dashTotalSales,
                  value: DashboardFormat.money(data.totalAmount),
                ),
              ),
              const SizedBox(width: AppSizes.sm),
              Expanded(
                child: _StatTile(
                  label: AppStrings.dashHighest,
                  value: data.hasData
                      ? AppStrings.dashPeakValue(
                    data.peakLabel,
                    DashboardFormat.compact(data.maxAmount),
                  )
                      : AppStrings.emptyValue,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.sm),
          Row(
            children: [
              Expanded(
                child: _StatTile(
                  label: AppStrings.dashOrders,
                  value: '${data.orderCount}',
                ),
              ),
              const SizedBox(width: AppSizes.sm),
              Expanded(
                child: _StatTile(
                  label: AppStrings.dashItemsSold,
                  value: '${data.itemCount}',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;

  const _StatTile({required this.label, required this.value});

  /// Tile tint — no AppColors token fits, flagged.
  static const double _tintAlpha = 0.06;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.sm + AppSizes.xs),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: _tintAlpha),
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      ),
      child: DashboardMetric(label: label, value: value),
    );
  }
}