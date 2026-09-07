import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_color_scheme.dart';
import '../../../../core/widgets/common/custom_card.dart';
import '../../../../core/widgets/common/status_badge.dart';

enum NotificationCategory { alert, order, system }

/// Single notification row — colored left accent, category tag +
/// relative time, title, and a one-line description. Unread items
/// get a tinted background via [isUnread].
class NotificationTile extends StatelessWidget {
  final NotificationCategory category;
  final String title;
  final String description;
  final String time;
  final bool isUnread;
  final VoidCallback? onTap;

  const NotificationTile({
    super.key,
    required this.category,
    required this.title,
    required this.description,
    required this.time,
    this.isUnread = false,
    this.onTap,
  });

  Color get _accentColor {
    switch (category) {
      case NotificationCategory.alert:
        return AppColors.error;
      case NotificationCategory.order:
        return AppColors.success;
      case NotificationCategory.system:
        return AppColors.primary;
    }
  }

  String get _categoryLabel {
    switch (category) {
      case NotificationCategory.alert:
        return 'ALERT';
      case NotificationCategory.order:
        return 'ORDER';
      case NotificationCategory.system:
        return 'SYSTEM';
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      accentColor: _accentColor,
      tinted: isUnread,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              StatusBadge(
                text: _categoryLabel,
                type: switch (category) {
                  NotificationCategory.alert => StatusBadgeType.error,
                  NotificationCategory.order => StatusBadgeType.success,
                  NotificationCategory.system => StatusBadgeType.primary,
                },
                shape: StatusBadgeShape.square,
                compact: true,
              ),              Text(
                time,
                style: TextStyle(fontSize: AppSizes.fontXs, color: context.appColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.sm),
          Text(
            title,
            style: TextStyle(
              fontSize: AppSizes.fontMd,
              fontWeight: isUnread ? FontWeight.w700 : FontWeight.w500,
              color: context.appColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSizes.xs / 2),
          Text(
            description,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: AppSizes.fontSm, color: context.appColors.textSecondary),
          ),
        ],
      ),
    );
  }
}