import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_color_scheme.dart';
import '../../../../core/widgets/common/settings_group.dart';
import '../../../../core/widgets/utility/custom_network_image.dart';
import 'profile_info_row.dart';

/// COMPANY group: logo with company name (and product), then company code
/// and branch (name, or its ID when the session has no name).
class ProfileCompanySection extends StatelessWidget {
  final String? companyName;
  final String? product;
  final String? logoUrl;
  final String? companyCode;
  final String? branchName;
  final int? branchId;

  const ProfileCompanySection({
    super.key,
    required this.companyName,
    required this.product,
    required this.logoUrl,
    required this.companyCode,
    required this.branchName,
    required this.branchId,
  });

  /// Branch name; sessions saved before login sent it fall back to the ID.
  String? get _branchText {
    final name = branchName?.trim();
    if (name != null && name.isNotEmpty) return name;
    return branchId?.toString();
  }

  @override
  Widget build(BuildContext context) {
    return SettingsGroup(
      label: AppStrings.profileCompanySection,
      children: [
        _BrandRow(name: companyName, product: product, logoUrl: logoUrl),
        ProfileInfoRow(
          icon: Icons.qr_code_2_rounded,
          label: AppStrings.companyCodeLabel,
          value: companyCode,
        ),
        ProfileInfoRow(
          icon: Icons.store_mall_directory_outlined,
          label: AppStrings.profileBranchLabel,
          value: _branchText,
        ),
      ],
    );
  }
}

class _BrandRow extends StatelessWidget {
  final String? name;
  final String? product;
  final String? logoUrl;

  const _BrandRow({required this.name, required this.product, required this.logoUrl});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final hasLogo = logoUrl != null && logoUrl!.isNotEmpty;
    final productText = product?.trim();

    return Padding(
      padding: const EdgeInsets.all(AppSizes.md),
      child: Row(
        children: [
          if (hasLogo)
            CustomNetworkImage(
              url: logoUrl!,
              width: AppSizes.xxl,
              height: AppSizes.xxl,
              fit: BoxFit.contain,
              backgroundColor: AppColors.surface,
              borderRadius: BorderRadius.circular(AppSizes.radiusSm),
            )
          else
            SizedBox.square(
              dimension: AppSizes.xxl,
              child: Icon(Icons.business_rounded, color: colors.textHint),
            ),
          const SizedBox(width: AppSizes.sm + AppSizes.xs),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  (name == null || name!.trim().isEmpty)
                      ? AppStrings.emptyValue
                      : name!.trim(),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: AppSizes.fontMd,
                    fontWeight: FontWeight.w700,
                    color: colors.textPrimary,
                  ),
                ),
                if (productText != null && productText.isNotEmpty)
                  Text(
                    productText,
                    style: TextStyle(
                      fontSize: AppSizes.fontXs,
                      color: colors.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
