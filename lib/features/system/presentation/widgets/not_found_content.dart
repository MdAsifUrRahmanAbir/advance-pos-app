import 'package:flutter/material.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_color_scheme.dart';
import '../../../../core/widgets/common/app_svg_icon.dart';
import '../../../../core/widgets/common/primary_button.dart';

/// Icon mark, "404" code, title/subtitle, and a "Back to Home"
/// button. Purely presentational — the navigation action is supplied
/// by the caller via [onBackToHome].
class NotFoundContent extends StatelessWidget {
  final VoidCallback? onBackToHome;

  const NotFoundContent({super.key, this.onBackToHome});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AppSvgIcon(
          assetPath: AppAssets.notFoundSVG,
          color: AppColors.primary,
          size: AppSizes.xxl * 2 + AppSizes.xl,
        ),
        const SizedBox(height: AppSizes.xxl),
         Text(
          AppStrings.notFoundCode,
          style: TextStyle(
            fontSize: AppSizes.fontDisplay * 2,
            fontWeight: FontWeight.w800,
            color: AppColors.primary,
            height: 1,
          ),
        ),
        const SizedBox(height: AppSizes.sm + AppSizes.xs),
         Text(
          AppStrings.notFoundTitle,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: AppSizes.fontXxl, fontWeight: FontWeight.w700, color: context.appColors.textPrimary),
        ),
        const SizedBox(height: AppSizes.sm),
         Text(
          AppStrings.notFoundSubtitle,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: AppSizes.fontMd, color: context.appColors.textSecondary, height: 1.5),
        ),
        const SizedBox(height: AppSizes.xxl),
        PrimaryButton(
          label: AppStrings.backToHome,
          onPressed: onBackToHome,
        ),
      ],
    );
  }
}