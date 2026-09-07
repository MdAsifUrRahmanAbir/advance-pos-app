import 'package:flutter/material.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_color_scheme.dart';
import '../../../../core/widgets/common/custom_icon_badge.dart';

/// Key icon badge + "Forgot Password?" heading + subtitle at the top
/// of the forgot-password screen.
class ForgotPasswordHeader extends StatelessWidget {
  const ForgotPasswordHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomIconBadge(
          icon: Icons.vpn_key_outlined,
          variant: IconBadgeVariant.filled,
        ),
        SizedBox(height: AppSizes.xl),
        Text(
          AppStrings.forgotPasswordTitle,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: AppSizes.fontDisplay, fontWeight: FontWeight.w700, color: context.appColors.textPrimary),
        ),
        SizedBox(height: AppSizes.sm),
        Text(
          AppStrings.forgotPasswordSubtitle,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: AppSizes.fontMd, color: context.appColors.textSecondary),
        ),
      ],
    );
  }
}