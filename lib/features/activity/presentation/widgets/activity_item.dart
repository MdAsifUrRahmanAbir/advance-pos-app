import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_color_scheme.dart';
import '../../../../core/widgets/common/custom_card.dart';
import '../../../../core/widgets/common/square_icon_tile.dart';
import '../../../../core/widgets/utility/timeline_indicator.dart';

enum ActivityStatus { success, warning, neutral }

/// Single row in the Activity Logs timeline — a colored timeline dot
/// on the left, and a card on the right with an icon, title,
/// description, timestamp, and a chevron affordance.
class ActivityItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String time;
  final ActivityStatus status;
  final bool isLast;
  final VoidCallback? onTap;

  const ActivityItem({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.time,
    this.status = ActivityStatus.neutral,
    this.isLast = false,
    this.onTap,
  });

  Color get _statusColor {
    switch (status) {
      case ActivityStatus.success:
        return AppColors.success;
      case ActivityStatus.warning:
        return AppColors.warning;
      case ActivityStatus.neutral:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 10 : 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TimelineIndicator(color: _statusColor, showLine: !isLast),
          const SizedBox(width: AppSizes.md),
          Expanded(
            child: CustomCard(
              onTap: onTap,
              padding: const EdgeInsets.all(AppSizes.md),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SquareIconTile(icon: icon, color: AppColors.primary, tinted: false),
                  const SizedBox(width: AppSizes.sm + AppSizes.xs),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: AppSizes.fontMd,
                            fontWeight: FontWeight.w600,
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
                        const SizedBox(height: AppSizes.xs / 2),
                        Text(
                          time,
                          style: TextStyle(fontSize: AppSizes.fontXs, color: context.appColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded, size: AppSizes.iconSm, color: context.appColors.textHint),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}