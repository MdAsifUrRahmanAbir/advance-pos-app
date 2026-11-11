import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_color_scheme.dart';
import '../../../../core/widgets/common/custom_network_image.dart';

/// Greeting 👋, the signed-in person's name in large type, the company
/// beneath, and the store logo with an online/offline dot.
class HomeHeader extends StatelessWidget {
  final String greeting;
  final String name;
  final String subtitle;
  final String? logoUrl;
  final bool isOnline;

  const HomeHeader({
    super.key,
    required this.greeting,
    required this.name,
    required this.subtitle,
    required this.logoUrl,
    required this.isOnline,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.homeGreetingWave(greeting),
                style: TextStyle(
                  color: colors.textSecondary,
                  fontSize: AppSizes.fontMd,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: AppSizes.xs),
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: colors.textPrimary,
                  fontSize: AppSizes.fontDisplay,
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (subtitle.isNotEmpty) ...[
                const SizedBox(height: AppSizes.xs / 2),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontSize: AppSizes.fontMd,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: AppSizes.md),
        _StoreBadge(logoUrl: logoUrl, isOnline: isOnline),
      ],
    );
  }
}

class _StoreBadge extends StatelessWidget {
  final String? logoUrl;
  final bool isOnline;

  const _StoreBadge({required this.logoUrl, required this.isOnline});

  /// FLAG: no avatar/dot size tokens.
  static const double _size = 52;
  static const double _dotSize = 14;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final logo = logoUrl;
    const inner = _size - AppSizes.sm * 2;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: _size,
          height: _size,
          padding: const EdgeInsets.all(AppSizes.sm),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(AppSizes.radiusLg),
            border: Border.all(color: colors.border),
          ),
          child: logo == null
              ? const Icon(
            Icons.storefront_rounded,
            color: AppColors.primary,
            size: AppSizes.iconMd,
          )
              : CustomNetworkImage(
            url: logo,
            width: inner,
            height: inner,
            fit: BoxFit.contain,
            borderRadius: BorderRadius.zero,
            backgroundColor: colors.surface,
          ),
        ),
        Positioned(
          right: -AppSizes.xs / 2,
          bottom: -AppSizes.xs / 2,
          child: Tooltip(
            message: isOnline ? AppStrings.statusOnline : AppStrings.statusOffline,
            child: Container(
              width: _dotSize,
              height: _dotSize,
              decoration: BoxDecoration(
                color: isOnline ? AppColors.success : colors.textHint,
                shape: BoxShape.circle,
                border: Border.all(color: colors.surface, width: AppSizes.xs / 2),
              ),
            ),
          ),
        ),
      ],
    );
  }
}