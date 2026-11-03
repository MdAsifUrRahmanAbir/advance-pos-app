import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_color_scheme.dart';
import '../../../../core/widgets/common/square_icon_tile.dart';

/// Success hero of the sale-complete sheet: tinted check, title, subtitle.
class SaleCompleteHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const SaleCompleteHeader({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Column(
      children: [
        const SquareIconTile(
          icon: Icons.check_rounded,
          color: AppColors.success,
          iconSize: AppSizes.iconLg,
          padding: AppSizes.md,
          radius: AppSizes.radiusFull,
        ),
        const SizedBox(height: AppSizes.md),
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: colors.textPrimary,
            fontSize: AppSizes.fontXl,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: AppSizes.xs),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: colors.textSecondary,
            fontSize: AppSizes.fontSm,
          ),
        ),
      ],
    );
  }
}
