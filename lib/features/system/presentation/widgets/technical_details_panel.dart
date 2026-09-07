import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_color_scheme.dart';


/// Bordered panel showing a small-caps label and monospace error/log
/// text beneath it. Used on crash/error screens to surface technical
/// details without displacing the main error messaging.
class TechnicalDetailsPanel extends StatelessWidget {
  final String label;
  final String details;
  final Color textColor;

  const TechnicalDetailsPanel({
    super.key,
    this.label = 'TECHNICAL DETAILS',
    required this.details,
    this.textColor = AppColors.error,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
        border: Border.all(color: context.appColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: AppSizes.fontXs,
              fontWeight: FontWeight.w700,
              color: context.appColors.textSecondary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: AppSizes.sm),
          Text(
            details,
            style: TextStyle(
              fontSize: AppSizes.fontSm,
              fontFamily: 'monospace',
              color: textColor,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}