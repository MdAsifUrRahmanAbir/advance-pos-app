import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/common/custom_list_tile.dart';
import '../../../../core/widgets/common/square_icon_tile.dart';

/// Single row in the Recent Activity feed — icon, description, and a
/// relative timestamp. Wraps [CustomListTile] so it inherits the
/// standard list-row spacing and typography.
class RecentActivityItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String time;

  const RecentActivityItem({
    super.key,
    required this.icon,
    required this.title,
    required this.time,
    this.iconColor = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return CustomListTile(
      leading: SquareIconTile(icon: icon, color: iconColor, tinted: false),
      title: title,
      subtitle: time,
    );
  }
}