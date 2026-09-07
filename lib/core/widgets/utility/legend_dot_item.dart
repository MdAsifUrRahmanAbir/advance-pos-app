import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_sizes.dart';

/// Colored dot + label, with an optional trailing value on the same
/// row. Used for chart legends (top of a line chart) and breakdown
/// lists (donut chart key).
class LegendDotItem extends StatelessWidget {
  final Color color;
  final String label;
  final String? value;
  final bool expanded;

  const LegendDotItem({
    super.key,
    required this.color,
    required this.label,
    this.value,
    this.expanded = false,
  });

  @override
  Widget build(BuildContext context) {
    final row = Row(
      mainAxisSize: expanded ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: AppSizes.xs + AppSizes.xs / 2,
              height: AppSizes.xs + AppSizes.xs / 2,
              decoration: BoxDecoration(shape: BoxShape.circle, color: color),
            ),
            const SizedBox(width: AppSizes.xs + AppSizes.xs / 2),
            Text(
              label,
              style: const TextStyle(fontSize: AppSizes.fontXs, color: AppColors.textSecondary),
            ),
          ],
        ),
        if (value != null)
          Text(
            value!,
            style: const TextStyle(fontSize: AppSizes.fontXs, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
          ),
      ],
    );
    return expanded ? row : row;
  }
}