import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/common/icon_button.dart';
import '../../../../core/widgets/common/status_badge.dart';

/// Dashboard top bar: brand mark, online/offline status, notifications.
///
/// NOTE: StatusBadge has no "dot" shape (only pill/square), so the small
/// status dot from the Figma is composed here as a plain feature-local
/// Container next to a compact StatusBadge. If a dot indicator is needed
/// elsewhere too, consider adding `showDot` to StatusBadge itself instead
/// of repeating this composition per-feature.
class DashboardTopBar extends StatelessWidget {
  final bool isOnline;
  final VoidCallback onNotificationsTap;

  const DashboardTopBar({
    super.key,
    required this.isOnline,
    required this.onNotificationsTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.md,
        vertical: AppSizes.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: const Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            AppStrings.appBrandName,
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: AppSizes.fontXl,
              fontWeight: FontWeight.w800,
            ),
          ),
          Row(
            children: [
              StatusBadge(
                text: isOnline
                    ? AppStrings.statusOnline
                    : AppStrings.statusOffline,
                type: isOnline
                    ? StatusBadgeType.success
                    : StatusBadgeType.neutral,
                compact: true,
              ),
              const SizedBox(width: AppSizes.sm),
              AppIconButton(
                icon: Icons.notifications_none_rounded,
                onPressed: onNotificationsTap,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
