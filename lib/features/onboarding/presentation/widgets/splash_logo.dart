import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';

/// Rounded app-icon mark shown on the splash screen — a filled square
/// with a soft drop shadow and a simple outlined glyph inside.
class SplashLogo extends StatelessWidget {
  final double size;

  const SplashLogo({super.key, this.size = AppSizes.xxl + AppSizes.xl});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.2),
            blurRadius: AppSizes.xl,
            offset: const Offset(0, AppSizes.md),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Icon(Icons.hexagon_outlined, color: AppColors.textWhite, size: size * 0.5),
    );
  }
}