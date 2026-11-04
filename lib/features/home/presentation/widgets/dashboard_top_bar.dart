import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_color_scheme.dart';
import '../../../../core/widgets/common/status_badge.dart';
import '../../../../core/widgets/utility/custom_network_image.dart';

/// Dashboard header: company logo, greeting with the employee's name, the
/// branch name, and an online/offline badge.
class DashboardTopBar extends StatelessWidget {
  final bool isOnline;
  final VoidCallback onNotificationsTap;
  final String title;
  final String? subtitle;
  final String? logoUrl;

  const DashboardTopBar({
    super.key,
    required this.isOnline,
    required this.onNotificationsTap,
    this.title = AppStrings.appBrandName,
    this.subtitle,
    this.logoUrl,
  });

  /// Logo tile size — no AppSizes token fits, flagged.
  static const double _logoSize = 44;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final logo = logoUrl;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        AppSizes.md,
        AppSizes.sm,
        AppSizes.md,
        AppSizes.sm + AppSizes.xs,
      ),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(bottom: BorderSide(color: colors.border)),
      ),
      child: Row(
        children: [
          Container(
            width: _logoSize,
            height: _logoSize,
            padding: const EdgeInsets.all(AppSizes.xs),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              border: Border.all(color: colors.border),
            ),
            child: logo == null
                ? const Icon(Icons.storefront_rounded, color: AppColors.primary)
                : CustomNetworkImage(
                    url: logo,
                    width: _logoSize - AppSizes.xs * 2,
                    height: _logoSize - AppSizes.xs * 2,
                    fit: BoxFit.contain,
                    borderRadius: BorderRadius.zero,
                    backgroundColor: AppColors.surface,
                  ),
          ),
          const SizedBox(width: AppSizes.sm + AppSizes.xs),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (subtitle != null && subtitle!.isNotEmpty)
                  Text(
                    subtitle!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: colors.textSecondary,
                      fontSize: AppSizes.fontXs,
                    ),
                  ),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: AppSizes.fontLg,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSizes.sm),
          StatusBadge(
            text: isOnline ? AppStrings.statusOnline : AppStrings.statusOffline,
            type: isOnline ? StatusBadgeType.success : StatusBadgeType.neutral,
            compact: true,
          ),
        ],
      ),
    );
  }
}
