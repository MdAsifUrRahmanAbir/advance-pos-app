import 'package:flutter/material.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import 'splash_style.dart';

/// Three glass chips hinting at what the app does.
class SplashFeatureChips extends StatelessWidget {
  const SplashFeatureChips({super.key});

  @override
  Widget build(BuildContext context) {
    return const Wrap(
      alignment: WrapAlignment.center,
      spacing: AppSizes.md,
      runSpacing: AppSizes.md,
      children: [
        _Chip(icon: Icons.point_of_sale_rounded, label: AppStrings.splashChipSales),
        _Chip(icon: Icons.inventory_2_rounded, label: AppStrings.splashChipInventory),
        _Chip(icon: Icons.bar_chart_rounded, label: AppStrings.splashChipReports),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _Chip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.md,
        vertical: AppSizes.xs,
      ),
      decoration: BoxDecoration(
        color: SplashStyle.onPrimary.withValues(alpha: SplashStyle.glassAlpha),
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(
          color: SplashStyle.onPrimary.withValues(alpha: SplashStyle.borderAlpha),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: AppSizes.lg, color: SplashStyle.onPrimary),
          const SizedBox(width: AppSizes.xs),
          Text(
            label,
            style: const TextStyle(
              fontSize: AppSizes.fontSm,
              fontWeight: FontWeight.w600,
              color: SplashStyle.onPrimary,
            ),
          ),
        ],
      ),
    );
  }
}