import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_sizes.dart';
import '../../theme/app_color_scheme.dart';

/// Single checklist row used under password fields — a small round
/// check icon (tinted green when [met], gray otherwise) + a label.
/// Reusable anywhere a password-strength checklist is needed
/// (reset password, change password, register).
class PasswordRequirementItem extends StatelessWidget {
  final String label;
  final bool met;

  const PasswordRequirementItem({
    super.key,
    required this.label,
    this.met = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.xs / 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: AppSizes.iconSm + AppSizes.xs,
            height: AppSizes.iconSm + AppSizes.xs,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: met ? AppColors.success.withValues(alpha: 0.12) : AppColors.divider,
            ),
            alignment: Alignment.center,
            child: Icon(
              Icons.check_rounded,
              size: AppSizes.iconSm - AppSizes.xs / 2,
              color: met ? AppColors.success : AppColors.textHint,
            ),
          ),
          const SizedBox(width: AppSizes.sm),
          Text(
            label,
            style: TextStyle(
              fontSize: AppSizes.fontSm,
              fontWeight: FontWeight.w500,
              color: met ? context.appColors.textPrimary : context.appColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}