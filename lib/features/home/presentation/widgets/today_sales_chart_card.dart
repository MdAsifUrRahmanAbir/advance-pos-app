import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_color_scheme.dart';
import '../../../../core/widgets/common/custom_card.dart';
import '../../../../core/widgets/utility/multi_line_chart.dart';

/// Today's hourly revenue trend — the "Graph/Chart" section on Home.
class TodaySalesChartCard extends StatelessWidget {
  final List<double> hourlyRevenue;
  final List<String> hourlyLabels;

  const TodaySalesChartCard({
    super.key,
    required this.hourlyRevenue,
    required this.hourlyLabels,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.todaySalesTrendTitle,
            style: TextStyle(fontSize: AppSizes.fontMd, fontWeight: FontWeight.w700, color: context.appColors.textPrimary),
          ),
          const SizedBox(height: AppSizes.md),
          MultiLineChart(
            series: [
              ChartSeries(label: AppStrings.todayRevenueLabel, color: AppColors.primary, values: hourlyRevenue),
            ],
            yAxisLabels: const ['5k', '2.5k', '0'],
            xAxisLabels: hourlyLabels,
            height: 180,
          ),
        ],
      ),
    );
  }
}