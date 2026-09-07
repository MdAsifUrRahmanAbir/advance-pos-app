import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_color_scheme.dart';
import '../../../../core/widgets/common/custom_card.dart';
import '../../../../core/widgets/utility/legend_dot_item.dart';
import '../../../../core/widgets/utility/multi_line_chart.dart';
import '../../../../core/widgets/utility/custom_filter_bar.dart';

/// Card containing the Revenue vs Expenses dual-line chart, its
/// legend, and a Day/Week/Month range toggle. The toggle reports
/// changes up via [onRangeChanged]; the chart data itself is
/// supplied by the caller so this widget stays presentation-only.
class RevenueExpenseChartCard extends StatelessWidget {
  final String selectedRange;
  final ValueChanged<String> onRangeChanged;
  final List<double> revenueValues;
  final List<double> expenseValues;
  final List<String> yAxisLabels;
  final List<String> xAxisLabels;

  const RevenueExpenseChartCard({
    super.key,
    required this.selectedRange,
    required this.onRangeChanged,
    required this.revenueValues,
    required this.expenseValues,
    required this.yAxisLabels,
    required this.xAxisLabels,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.revenueVsExpenses,
                    style: TextStyle(fontSize: AppSizes.fontMd, fontWeight: FontWeight.w700, color: context.appColors.textPrimary),
                  ),
                  const SizedBox(height: AppSizes.xs),
                  Row(
                    children: const [
                      LegendDotItem(color: AppColors.primary, label: AppStrings.revenueLabel),
                      SizedBox(width: AppSizes.sm + AppSizes.xs),
                      LegendDotItem(color: AppColors.warning, label: AppStrings.expensesLabel),
                    ],
                  ),
                ],
              ),
              CustomFilterBar<String>(
                filters: const ['D', 'W', 'M'],
                selectedFilters: {selectedRange},
                labelBuilder: (f) => f,
                onSelected: onRangeChanged,
              ),
            ],
          ),
          const SizedBox(height: AppSizes.md),
          MultiLineChart(
            series: [
              ChartSeries(label: AppStrings.revenueLabel, color: AppColors.primary, values: revenueValues),
              ChartSeries(label: AppStrings.expensesLabel, color: AppColors.warning, values: expenseValues),
            ],
            yAxisLabels: yAxisLabels,
            xAxisLabels: xAxisLabels,
          ),
        ],
      ),
    );
  }
}