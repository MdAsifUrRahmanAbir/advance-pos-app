import 'package:flutter/material.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_color_scheme.dart';
import '../../../../core/widgets/common/custom_card.dart';
import '../../../../core/widgets/utility/donut_chart.dart';
import '../../../../core/widgets/utility/legend_dot_item.dart';

class CategoryShare {
  final String label;
  final double percent;
  final Color color;

  const CategoryShare({required this.label, required this.percent, required this.color});
}

/// Card containing the category-breakdown donut chart and a
/// legend/percentage list underneath.
class CategoryBreakdownCard extends StatelessWidget {
  final List<CategoryShare> shares;
  final String centerLabel;

  const CategoryBreakdownCard({super.key, required this.shares, required this.centerLabel});

  @override
  Widget build(BuildContext context) {
    final top = shares.reduce((a, b) => a.percent > b.percent ? a : b);

    return CustomCard(
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              AppStrings.categoryBreakdown,
              style: TextStyle(fontSize: AppSizes.fontMd, fontWeight: FontWeight.w700, color: context.appColors.textPrimary),
            ),
          ),
          const SizedBox(height: AppSizes.md),
          DonutChart(
            segments: [for (final s in shares) DonutSegment(value: s.percent, color: s.color)],
            centerValue: '${top.percent.toStringAsFixed(0)}%',
            centerLabel: centerLabel,
          ),
          const SizedBox(height: AppSizes.md),
          Column(
            children: [
              for (final s in shares) ...[
                LegendDotItem(color: s.color, label: s.label, value: '${s.percent.toStringAsFixed(0)}%', expanded: true),
                const SizedBox(height: AppSizes.sm),
              ],
            ],
          ),
        ],
      ),
    );
  }
}