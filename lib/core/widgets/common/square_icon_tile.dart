import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_sizes.dart';

/// Small rounded-square icon tile with a tinted background. Reused
/// for stat card icons, quick action tiles, and activity list
/// leading icons wherever a compact "icon in a soft box" look is
/// needed.
class SquareIconTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double iconSize;
  final double padding;
  final double radius;
  final bool tinted;

  const SquareIconTile({
    super.key,
    required this.icon,
    this.color = AppColors.primary,
    this.iconSize = AppSizes.iconMd,
    this.padding = AppSizes.sm,
    this.radius = AppSizes.radiusSm,
    this.tinted = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: tinted ? color.withValues(alpha: 0.1) : AppColors.divider,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Icon(icon, size: iconSize, color: color),
    );
  }
}