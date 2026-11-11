import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_color_scheme.dart';
import '../../../../core/widgets/common/custom_card.dart';
import '../states/dashboard_format.dart';
import '../states/home_state.dart';
import 'dashboard_segmented_toggle.dart';

/// Sales trend: icon header with its own range toggle, the period total
/// with the best day/month, a rounded bar chart (peak highlighted), and
/// Orders · Items Sold · Avg per order underneath.
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

  /// FLAG: no icon-tile / tint tokens.
  static const double _iconTileSize = 40;
  static const double _tintAlpha = 0.12;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final avg = data.orderCount > 0 ? data.totalAmount / data.orderCount : 0.0;

    return CustomCard(
      padding: const EdgeInsets.all(AppSizes.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: _iconTileSize,
                height: _iconTileSize,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: _tintAlpha),
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                ),
                child: const Icon(
                  Icons.insights_rounded,
                  color: AppColors.primary,
                  size: AppSizes.iconMd,
                ),
              ),
              const SizedBox(width: AppSizes.sm + AppSizes.xs),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.dashSalesTrend,
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontSize: AppSizes.fontMd,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      data.isMonthlyRange
                          ? AppStrings.homeLast12Months
                          : AppStrings.homeLast7Days,
                      style: TextStyle(
                        color: colors.textSecondary,
                        fontSize: AppSizes.fontXs,
                      ),
                    ),
                  ],
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

          // Total + best period
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    DashboardFormat.money(data.totalAmount),
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontSize: AppSizes.fontXxl,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              if (data.hasData)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.sm,
                    vertical: AppSizes.xs,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: _tintAlpha),
                    borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.arrow_upward_rounded,
                        size: AppSizes.iconSm,
                        color: AppColors.success,
                      ),
                      const SizedBox(width: AppSizes.xs / 2),
                      Text(
                        AppStrings.homeHighest(
                          AppStrings.dashPeakValue(
                            data.peakLabel,
                            DashboardFormat.compact(data.maxAmount),
                          ),
                        ),
                        style: const TextStyle(
                          color: AppColors.success,
                          fontSize: AppSizes.fontXs,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSizes.md),

          // Chart
          if (data.hasData)
            Skeleton.leaf(child: _BarChart(data: data))
          else
            SizedBox(
              height: _BarChart.height,
              child: Center(
                child: Text(
                  AppStrings.dashNoData,
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontSize: AppSizes.fontSm,
                  ),
                ),
              ),
            ),
          const SizedBox(height: AppSizes.md),

          // Orders · Items · Avg
          Container(
            padding: const EdgeInsets.symmetric(vertical: AppSizes.sm + AppSizes.xs),
            decoration: BoxDecoration(
              border: Border.all(color: colors.border),
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            ),
            child: IntrinsicHeight(
              child: Row(
                children: [
                  Expanded(
                    child: _TotalCell(
                      label: AppStrings.dashOrders,
                      value: '${data.orderCount}',
                    ),
                  ),
                  VerticalDivider(width: 1, color: colors.border),
                  Expanded(
                    child: _TotalCell(
                      label: AppStrings.dashItemsSold,
                      value: '${data.itemCount}',
                    ),
                  ),
                  VerticalDivider(width: 1, color: colors.border),
                  Expanded(
                    child: _TotalCell(
                      label: AppStrings.homeAvgPerOrder,
                      value: data.orderCount > 0
                          ? DashboardFormat.money(avg)
                          : AppStrings.emptyValue,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// One rounded bar per label; the highest bar is solid and shows its
/// value, the rest are tinted. Heights animate when the range changes.
class _BarChart extends StatelessWidget {
  final SalesTrendData data;

  const _BarChart({required this.data});

  /// FLAG: no chart tokens.
  static const double height = 150;
  static const double _barAlpha = 0.25;
  static const double _minBar = AppSizes.xs;
  static const Duration _duration = Duration(milliseconds: 350);

  /// Room for the peak value above and the label below the bars.
  static const double _reserved = AppSizes.xl + AppSizes.sm;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final values = data.values;

    var peak = 0;
    for (var i = 1; i < values.length; i++) {
      if (values[i] > values[peak]) peak = i;
    }
    final top = data.maxAmount > 0
        ? data.maxAmount
        : (values.isEmpty ? 0.0 : values[peak]);
    const barSpace = height - _reserved;

    return SizedBox(
      height: height,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (var i = 0; i < values.length; i++)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.xs / 2),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (i == peak && values[i] > 0)
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          DashboardFormat.compact(values[i]),
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: AppSizes.fontXs,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    const SizedBox(height: AppSizes.xs / 2),
                    AnimatedContainer(
                      duration: _duration,
                      curve: Curves.easeOutCubic,
                      height: top > 0
                          ? (barSpace * (values[i] / top)).clamp(_minBar, barSpace)
                          : _minBar,
                      decoration: BoxDecoration(
                        color: i == peak
                            ? AppColors.primary
                            : AppColors.primary.withValues(alpha: _barAlpha),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(AppSizes.radiusSm),
                          bottom: Radius.circular(AppSizes.xs / 2),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSizes.xs),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        i < data.labels.length ? data.labels[i] : '',
                        maxLines: 1,
                        style: TextStyle(
                          color: i == peak ? colors.textPrimary : colors.textSecondary,
                          fontSize: AppSizes.fontXs,
                          fontWeight: i == peak ? FontWeight.w700 : FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _TotalCell extends StatelessWidget {
  final String label;
  final String value;

  const _TotalCell({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.xs),
      child: Column(
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: colors.textSecondary, fontSize: AppSizes.fontXs),
          ),
          const SizedBox(height: AppSizes.xs / 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: AppSizes.fontMd,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}