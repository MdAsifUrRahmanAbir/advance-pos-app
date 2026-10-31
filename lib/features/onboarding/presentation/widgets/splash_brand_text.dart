import 'package:flutter/material.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import 'splash_style.dart';

/// App name + headline shown below the logo.
class SplashBrandText extends StatelessWidget {
  const SplashBrandText({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          AppStrings.appName,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: AppSizes.fontDisplay,
            fontWeight: FontWeight.w700,
            color: SplashStyle.onPrimary,
          ),
        ),
        const SizedBox(height: AppSizes.xs),
        Text(
          AppStrings.splashHeadline,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: AppSizes.fontMd,
            color: SplashStyle.onPrimary.withValues(
              alpha: SplashStyle.softTextAlpha,
            ),
          ),
        ),
      ],
    );
  }
}