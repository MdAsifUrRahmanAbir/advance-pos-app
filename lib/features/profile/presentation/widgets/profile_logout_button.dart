import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';

/// Full-width, error-tinted Log Out button at the bottom of the profile —
/// same look as the Log Out button in Settings.
class ProfileLogoutButton extends StatelessWidget {
  final VoidCallback? onTap;
  final bool isLoading;

  const ProfileLogoutButton({super.key, this.onTap, this.isLoading = false});

  /// Tint behind the label — no AppColors token, flagged.
  static const double _tintAlpha = 0.08;

  /// Spinner stroke — no AppSizes token, flagged.
  static const double _spinnerStroke = 2;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: AppSizes.buttonHeight,
      child: TextButton.icon(
        onPressed: isLoading ? null : onTap,
        style: TextButton.styleFrom(
          backgroundColor: AppColors.error.withValues(alpha: _tintAlpha),
          foregroundColor: AppColors.error,
          disabledForegroundColor: AppColors.error,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          ),
        ),
        icon: isLoading
            ? const SizedBox.square(
                dimension: AppSizes.iconSm,
                child: CircularProgressIndicator(
                  strokeWidth: _spinnerStroke,
                  color: AppColors.error,
                ),
              )
            : const Icon(Icons.logout_rounded, size: AppSizes.iconSm),
        label: const Text(
          AppStrings.logOut,
          style: TextStyle(
            fontSize: AppSizes.fontMd,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
