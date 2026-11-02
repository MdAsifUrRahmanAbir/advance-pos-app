import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_color_scheme.dart';
import '../../../../core/widgets/common/link_button.dart';
import '../../../../core/widgets/utility/custom_network_image.dart';

/// Bottom of the sign-in screen: which company this device is connected
/// to (logo, name + the code the user entered) and a "Switch" action.
/// Falls back to a store icon when there is no logo or it fails to load.
class LoginCompanyFooter extends StatelessWidget {
  final String name;
  final String compCode;
  final String logoUrl;
  final VoidCallback? onSwitch;

  const LoginCompanyFooter({
    super.key,
    required this.name,
    required this.compCode,
    this.logoUrl = '',
    this.onSwitch,
  });

  static const Widget _fallbackIcon = Icon(
    Icons.storefront_outlined,
    size: AppSizes.iconMd,
    color: AppColors.primary,
  );

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppSizes.lg,
        AppSizes.sm,
        AppSizes.lg,
        AppSizes.md,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.md,
        vertical: AppSizes.sm + AppSizes.xs,
      ),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          logoUrl.isEmpty
              ? _fallbackIcon
              : CustomNetworkImage(
            url: logoUrl,
            width: AppSizes.iconLg,
            height: AppSizes.iconLg,
            fit: BoxFit.contain,
            backgroundColor: AppColors.surface,
            borderRadius: BorderRadius.circular(AppSizes.radiusSm),
            errorWidget: _fallbackIcon,
          ),
          const SizedBox(width: AppSizes.sm + AppSizes.xs),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.companyConnectedLabel,
                  style: TextStyle(
                    fontSize: AppSizes.fontXs,
                    color: colors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSizes.xs / 2),
                Text(
                  compCode.isEmpty ? name : AppStrings.companyNameWithCode(name, compCode),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: AppSizes.fontSm,
                    fontWeight: FontWeight.w600,
                    color: colors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSizes.sm),
          LinkButton(
            label: AppStrings.companySwitchAction,
            fontSize: AppSizes.fontSm,
            onPressed: onSwitch,
          ),
        ],
      ),
    );
  }
}