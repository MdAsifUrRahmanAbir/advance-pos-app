import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_color_scheme.dart';

/// App version label, plus destructive Log Out / Delete Account
/// actions at the bottom of the settings list.
class SettingsFooterActions extends StatelessWidget {
  final String versionLabel;
  final VoidCallback? onLogOutTap;
  final VoidCallback? onDeleteAccountTap;

  const SettingsFooterActions({
    super.key,
    required this.versionLabel,
    this.onLogOutTap,
    this.onDeleteAccountTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          versionLabel,
          style: TextStyle(fontSize: AppSizes.fontSm, color: context.appColors.textSecondary),
        ),
        const SizedBox(height: AppSizes.sm + AppSizes.xs),
        SizedBox(
          width: double.infinity,
          height: AppSizes.xl + AppSizes.md,
          child: TextButton(
            onPressed: onLogOutTap,
            style: TextButton.styleFrom(
              backgroundColor: AppColors.error.withValues(alpha: 0.08),
              foregroundColor: AppColors.error,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusSm)),
            ),
            child:  Text(
              AppStrings.logOut,
              style: TextStyle(fontSize: AppSizes.fontMd, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        const SizedBox(height: AppSizes.sm + AppSizes.xs),
        SizedBox(
          width: double.infinity,
          height: AppSizes.xl + AppSizes.md,
          child: OutlinedButton(
            onPressed: onDeleteAccountTap,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.error,
              side: const BorderSide(color: AppColors.error),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusSm)),
            ),
            child:  Text(
              AppStrings.deleteAccount,
              style: TextStyle(fontSize: AppSizes.fontMd, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }
}