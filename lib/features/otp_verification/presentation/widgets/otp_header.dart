import 'package:flutter/material.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_color_scheme.dart';
import '../../../../core/widgets/common/custom_icon_badge.dart';

/// Icon badge + "Verify Your Account" heading + subtitle at the top of
/// the OTP verification screen.
class OtpHeader extends StatelessWidget {
  const OtpHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const CustomIconBadge(icon: Icons.error_outline_rounded),
        const SizedBox(height: AppSizes.lg),
         Text(
          AppStrings.verifyYourAccount,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: AppSizes.fontXl, fontWeight: FontWeight.w700, color: context.appColors.textPrimary),
        ),
        const SizedBox(height: AppSizes.sm),
         Text(
          AppStrings.otpSubtitle,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: AppSizes.fontMd, color: context.appColors.textSecondary),
        ),
      ],
    );
  }
}