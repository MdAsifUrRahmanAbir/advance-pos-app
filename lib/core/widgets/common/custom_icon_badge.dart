import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_sizes.dart';
import '../../theme/app_color_scheme.dart';

enum IconBadgeVariant { outlined, filled }

/// Large circular icon badge for status/confirmation screens.
/// - [IconBadgeVariant.outlined]: white circle + border + shadow (OTP
///   verification, error states).
/// - [IconBadgeVariant.filled]: soft tinted circle, no border (forgot
///   password, empty states, success confirmations).
class CustomIconBadge extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;
  final double iconSize;
  final IconBadgeVariant variant;

  const CustomIconBadge({
    super.key,
    required this.icon,
    this.color = AppColors.primary,
    this.size = AppSizes.xxl * 2 + AppSizes.xs,
    this.iconSize = AppSizes.xxl,
    this.variant = IconBadgeVariant.outlined,
  });

  @override
  Widget build(BuildContext context) {
    final isFilled = variant == IconBadgeVariant.filled;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isFilled ? color.withValues(alpha: 0.1) : context.appColors.surface,
        border: isFilled ? null : Border.all(color: AppColors.border),
        boxShadow: isFilled
            ? null
            : [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: 0.02),
            blurRadius: AppSizes.md,
            offset: const Offset(0, AppSizes.xs),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Icon(icon, color: color, size: iconSize),
    );
  }
}