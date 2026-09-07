import 'package:flutter/material.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_color_scheme.dart';
import '../../../../core/widgets/common/app_svg_icon.dart';
import '../../../../core/widgets/common/primary_button.dart';
import '../../../../core/widgets/common/text_button.dart';

/// Wifi-off icon mark, title/subtitle, a "Check Connection" primary
/// action, and a "Work Offline" text link. Purely presentational —
/// both actions are supplied by the caller.
class NoInternetContent extends StatelessWidget {
  final VoidCallback? onCheckConnection;
  final VoidCallback? onWorkOffline;

  const NoInternetContent({
    super.key,
    this.onCheckConnection,
    this.onWorkOffline,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AppSvgIcon(
          assetPath: AppAssets.wifi,
          color: AppColors.warning,
          size: AppSizes.xxl * 2 + AppSizes.xl,
        ),
        const SizedBox(height: AppSizes.xl),
         Text(
          AppStrings.noInternetTitle,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: AppSizes.fontXxl,
            fontWeight: FontWeight.w700,
            color: context.appColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSizes.sm),
         Text(
          AppStrings.noInternetSubtitle,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: AppSizes.fontMd,
            color: context.appColors.textSecondary,
            height: 1.5,
          ),
        ),
        const SizedBox(height: AppSizes.xl),
        PrimaryButton(
          label: AppStrings.checkConnection,
          onPressed: onCheckConnection,
        ),
        const SizedBox(height: AppSizes.sm),
        AppTextButton(label: AppStrings.workOffline, onPressed: onWorkOffline),
      ],
    );
  }
}
