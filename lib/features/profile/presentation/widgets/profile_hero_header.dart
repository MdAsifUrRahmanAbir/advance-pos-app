import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/utility/custom_network_image.dart';

/// Gradient hero at the top of the profile: company logo (shown whole, in
/// a white tile), branch name, "company · product" and a company-code chip.
/// [extraBottomSpace] leaves room for a card that overlaps the hero's
/// bottom edge. [fullBleed] (phones) squares the top corners and pads for
/// the status bar; tablets get a fully rounded card.
class ProfileHeroHeader extends StatelessWidget {
  final String title;
  final String? companyName;
  final String? product;
  final String? logoUrl;
  final String? companyCode;
  final double extraBottomSpace;
  final bool fullBleed;

  const ProfileHeroHeader({
    super.key,
    required this.title,
    required this.companyName,
    required this.product,
    required this.logoUrl,
    required this.companyCode,
    this.extraBottomSpace = 0,
    this.fullBleed = true,
  });

  /// Logo tile size — no AppSizes token fits, flagged.
  static const double _logoSize = 72;

  /// White overlays on the gradient — no AppColors tokens, flagged.
  static const double _subtitleAlpha = 0.8;
  static const double _chipAlpha = 0.16;

  @override
  Widget build(BuildContext context) {
    final topInset = fullBleed ? MediaQuery.paddingOf(context).top : 0.0;
    final subtitle = [
      if (companyName?.trim() case final name? when name.isNotEmpty) name,
      if (product?.trim() case final p? when p.isNotEmpty) p,
    ].join(AppStrings.profileInfoSeparator);
    final code = companyCode?.trim();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        AppSizes.md,
        topInset + AppSizes.lg,
        AppSizes.md,
        AppSizes.lg + extraBottomSpace,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
        borderRadius: fullBleed
            ? const BorderRadius.vertical(
                bottom: Radius.circular(AppSizes.radiusXl),
              )
            : BorderRadius.circular(AppSizes.radiusXl),
      ),
      child: Column(
        children: [
          _LogoTile(url: logoUrl),
          const SizedBox(height: AppSizes.md),
          Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textWhite,
              fontSize: AppSizes.fontXl,
              fontWeight: FontWeight.w800,
            ),
          ),
          if (subtitle.isNotEmpty) ...[
            const SizedBox(height: AppSizes.xs),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textWhite.withValues(alpha: _subtitleAlpha),
                fontSize: AppSizes.fontSm,
              ),
            ),
          ],
          if (code != null && code.isNotEmpty) ...[
            const SizedBox(height: AppSizes.sm + AppSizes.xs),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.sm + AppSizes.xs,
                vertical: AppSizes.xs,
              ),
              decoration: BoxDecoration(
                color: AppColors.textWhite.withValues(alpha: _chipAlpha),
                borderRadius: BorderRadius.circular(AppSizes.radiusFull),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.qr_code_2_rounded,
                    size: AppSizes.iconSm,
                    color: AppColors.textWhite,
                  ),
                  const SizedBox(width: AppSizes.xs),
                  Text(
                    AppStrings.profileCompanyCodeChip(code),
                    style: const TextStyle(
                      color: AppColors.textWhite,
                      fontSize: AppSizes.fontXs,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// White rounded tile with the whole logo (never cropped); a business icon
/// when there is no logo.
class _LogoTile extends StatelessWidget {
  final String? url;

  const _LogoTile({required this.url});

  @override
  Widget build(BuildContext context) {
    final logo = url;
    return Container(
      width: ProfileHeroHeader._logoSize,
      height: ProfileHeroHeader._logoSize,
      padding: const EdgeInsets.all(AppSizes.sm),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      ),
      child: logo == null
          ? const Icon(
              Icons.storefront_rounded,
              size: AppSizes.iconLg,
              color: AppColors.primary,
            )
          : CustomNetworkImage(
              url: logo,
              width: ProfileHeroHeader._logoSize - AppSizes.sm * 2,
              height: ProfileHeroHeader._logoSize - AppSizes.sm * 2,
              fit: BoxFit.contain,
              borderRadius: BorderRadius.zero,
              backgroundColor: AppColors.surface,
            ),
    );
  }
}
