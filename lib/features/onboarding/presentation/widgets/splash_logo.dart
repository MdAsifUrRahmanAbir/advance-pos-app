import 'package:flutter/material.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_sizes.dart';
import 'splash_style.dart';

/// Glass-style app-icon tile shown on the primary splash background.
class SplashLogo extends StatelessWidget {
  final double size;

  const SplashLogo({super.key, this.size = AppSizes.xxl + AppSizes.xl});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: SplashStyle.onPrimary.withValues(alpha: SplashStyle.glassAlpha),
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(
          color: SplashStyle.onPrimary.withValues(alpha: SplashStyle.borderAlpha),
        ),
      ),
      child: Image.asset(AppAssets.splashLogo),
    );
  }
}