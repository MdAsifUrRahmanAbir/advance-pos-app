import 'package:flutter/material.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_color_scheme.dart';
import '../../../../core/widgets/common/link_button.dart';

/// "Don't have an account? Register" row shown at the bottom of the
/// sign-in screen.
class RegisterPrompt extends StatelessWidget {
  final VoidCallback? onRegisterTap;

  const RegisterPrompt({super.key, this.onRegisterTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
         Text(
          AppStrings.dontHaveAccount,
          style: TextStyle(fontSize: AppSizes.fontSm, color: context.appColors.textSecondary),
        ),
        LinkButton(
          label: AppStrings.register,
          fontSize: AppSizes.fontSm,
          onPressed: onRegisterTap,
        ),
      ],
    );
  }
}
