import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';

/// "View all (n)" / "Show less" link for the top lists' section headers.
class DashboardViewAllButton extends StatelessWidget {
  final int total;
  final bool expanded;
  final VoidCallback onTap;

  const DashboardViewAllButton({
    super.key,
    required this.total,
    required this.expanded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onTap,
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.sm),
        visualDensity: VisualDensity.compact,
        textStyle: const TextStyle(
          fontSize: AppSizes.fontSm,
          fontWeight: FontWeight.w700,
        ),
      ),
      iconAlignment: IconAlignment.end,
      icon: Icon(
        expanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
        size: AppSizes.iconSm,
      ),
      label: Text(expanded ? AppStrings.dashShowLess : AppStrings.dashViewAll(total)),
    );
  }
}