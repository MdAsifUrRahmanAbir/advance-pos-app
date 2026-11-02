import 'package:flutter/material.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_color_scheme.dart';
import '../../../../core/widgets/common/link_button.dart';

/// "Wrong company? Change company" row pinned at the bottom of the
/// sign-in screen.
class LoginChangeCompanyFooter extends StatelessWidget {
  final VoidCallback? onChangeCompany;

  const LoginChangeCompanyFooter({super.key, this.onChangeCompany});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.md),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            AppStrings.companyWrongPrompt,
            style: TextStyle(
              fontSize: AppSizes.fontSm,
              color: context.appColors.textSecondary,
            ),
          ),
          const SizedBox(width: AppSizes.xs),
          LinkButton(
            label: AppStrings.companyChangeAction,
            fontSize: AppSizes.fontSm,
            onPressed: onChangeCompany,
          ),
        ],
      ),
    );
  }
}