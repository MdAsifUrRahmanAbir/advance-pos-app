import 'package:flutter/material.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_color_scheme.dart';

/// Title + Export button row, plus the date-range pill beneath it.
class AnalyticsHeader extends StatelessWidget {
  final String dateRangeLabel;
  final VoidCallback? onExportTap;
  final VoidCallback? onDateRangeTap;

  const AnalyticsHeader({
    super.key,
    required this.dateRangeLabel,
    this.onExportTap,
    this.onDateRangeTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: context.appColors.surface,
        // border: Border(bottom: BorderSide(color: context.appColors.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppStrings.analyticsTitle,
                style: TextStyle(fontSize: AppSizes.fontXl, fontWeight: FontWeight.w700, color: context.appColors.textPrimary),
              ),
              OutlinedButton.icon(
                onPressed: onExportTap,
                style: OutlinedButton.styleFrom(
                  foregroundColor: context.appColors.textSecondary,
                  side: BorderSide(color: context.appColors.border),
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.sm + AppSizes.xs, vertical: AppSizes.xs),
                ),
                icon: Icon(Icons.expand_more_rounded, size: AppSizes.iconSm),
                label:  Text(AppStrings.exportLabel, style: TextStyle(fontSize: AppSizes.fontSm, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.sm + AppSizes.xs),
          InkWell(
            onTap: onDateRangeTap,
            borderRadius: BorderRadius.circular(AppSizes.radiusSm),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.sm + AppSizes.xs, vertical: AppSizes.sm),
              decoration: BoxDecoration(color: context.appColors.background, borderRadius: BorderRadius.circular(AppSizes.radiusSm)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                   Icon(Icons.calendar_today_outlined, size: AppSizes.iconSm, color: context.appColors.textSecondary),
                  const SizedBox(width: AppSizes.sm),
                  Text(dateRangeLabel, style: TextStyle(fontSize: AppSizes.fontSm, fontWeight: FontWeight.w500, color: context.appColors.textPrimary)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}