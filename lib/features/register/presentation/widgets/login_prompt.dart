import 'package:flutter/material.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_color_scheme.dart';
import '../../../../core/widgets/common/link_button.dart';

/// "Already have an account? Login" row shown at the bottom of the
/// register screen.
class LoginPrompt extends StatelessWidget {
  final VoidCallback? onLoginTap;

  const LoginPrompt({super.key, this.onLoginTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
         Text(
          AppStrings.alreadyHaveAccount,
          style: TextStyle(fontSize: AppSizes.fontSm, color: context.appColors.textSecondary),
        ),
        LinkButton(
          label: AppStrings.login,
          fontSize: AppSizes.fontSm,
          onPressed: onLoginTap,
        ),
      ],
    );
  }
}