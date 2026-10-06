import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/common/custom_card.dart';
import '../../../../core/widgets/utility/multi_line_chart.dart';
import '../states/dashboard_format.dart';
import '../states/home_state.dart';
import 'dashboard_metric.dart';
import 'dashboard_segmented_toggle.dart';

/// Sales trend with its own range toggle (7 days / 12 months) and a
/// totals footer.
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

  static const double _chartHeight = 180;

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
              const Text(
                AppStrings.dashSalesTrend,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: AppSizes.fontMd,
                  fontWeight: FontWeight.w700,
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
              ),
            )
          else
            const SizedBox(
              height: _chartHeight,
              child: Center(
                child: Text(
                  AppStrings.dashNoData,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: AppSizes.fontSm,
                  ),
                ),
              ),
            ),
          const SizedBox(height: AppSizes.md),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: AppSizes.md),
          Row(
            children: [
              Expanded(
                child: DashboardMetric(
                  label: AppStrings.dashTotalSales,
                  value: DashboardFormat.money(data.totalAmount),
                ),
              ),
              Expanded(
                child: DashboardMetric(
                  label: AppStrings.dashHighest,
                  value: data.hasData
                      ? AppStrings.dashPeakValue(
                    data.peakLabel,
                    DashboardFormat.compact(data.maxAmount),
                  )
                      : '-',
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.md),
          Row(
            children: [
              Expanded(
                child: DashboardMetric(
                  label: AppStrings.dashOrders,
                  value: '${data.orderCount}',
                ),
              ),
              Expanded(
                child: DashboardMetric(
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