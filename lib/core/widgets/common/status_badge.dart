import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_sizes.dart';

enum StatusBadgeType { success, warning, error, info, neutral, primary }
enum StatusBadgeShape { pill, square }

class StatusBadge extends StatelessWidget {
  final String text;
  final StatusBadgeType type;
  final IconData? icon;
  final bool compact;
  final StatusBadgeShape shape;

  const StatusBadge({
    super.key,
    required this.text,
    this.type = StatusBadgeType.neutral,
    this.icon,
    this.compact = false,
    this.shape = StatusBadgeShape.pill,
  });

  Color get _color {
    switch (type) {
      case StatusBadgeType.success:
        return AppColors.success;
      case StatusBadgeType.warning:
        return AppColors.warning;
      case StatusBadgeType.error:
        return AppColors.error;
      case StatusBadgeType.info:
        return AppColors.info;
      case StatusBadgeType.primary:
        return AppColors.primary;
      case StatusBadgeType.neutral:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _color;
    final isSquare = shape == StatusBadgeShape.square;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? AppSizes.sm : AppSizes.md,
        vertical: AppSizes.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isSquare ? 0.1 : 0.12),
        borderRadius: BorderRadius.circular(isSquare ? AppSizes.radiusSm - 2 : AppSizes.radiusFull),
        border: isSquare ? null : Border.all(color: color.withValues(alpha: 0.24)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: AppSizes.iconSm, color: color),
            const SizedBox(width: AppSizes.xs),
          ],
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: isSquare ? AppSizes.fontXs : AppSizes.fontSm,
              fontWeight: FontWeight.w600,
              letterSpacing: isSquare ? 0.3 : null,
            ),
          ),
        ],
      ),
    );
  }
}