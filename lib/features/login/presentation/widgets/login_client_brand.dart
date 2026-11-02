import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_color_scheme.dart';
import '../../../../core/widgets/common/link_button.dart';
import '../../../../core/widgets/utility/custom_network_image.dart';

/// Verified company's logo and name above the sign-in card, with a
/// "Change company" link back to company verification.
class LoginClientBrand extends StatelessWidget {
  final String name;
  final String logoUrl;
  final VoidCallback? onChangeCompany;

  const LoginClientBrand({
    super.key,
    required this.name,
    required this.logoUrl,
    this.onChangeCompany,
  });

  /// Logo box size — no AppSizes token this large, flagged.
  static const double _logoSize = 72;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Column(
      children: [
        if (logoUrl.isNotEmpty) ...[
          CustomNetworkImage(
            url: logoUrl,
            width: _logoSize,
            height: _logoSize,
            fit: BoxFit.contain,
            backgroundColor: AppColors.surface,
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          ),
          const SizedBox(height: AppSizes.sm),
        ],
        if (name.isNotEmpty)
          Text(
            name,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: AppSizes.fontXl,
              fontWeight: FontWeight.w700,
              color: colors.textPrimary,
            ),
          ),
        if (onChangeCompany != null) ...[
          const SizedBox(height: AppSizes.xs),
          LinkButton(
            label: AppStrings.companyChangeAction,
            fontSize: AppSizes.fontSm,
            onPressed: onChangeCompany,
          ),
        ],
      ],
    );
  }
}