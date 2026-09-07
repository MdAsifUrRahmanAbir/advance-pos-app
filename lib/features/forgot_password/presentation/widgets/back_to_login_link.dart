import 'package:flutter/material.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/common/link_button.dart';

/// "Back to Login" link shown at the bottom of the forgot-password
/// screen.
class BackToLoginLink extends StatelessWidget {
  final VoidCallback? onTap;

  const BackToLoginLink({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: LinkButton(
        label: AppStrings.backToLogin,
        onPressed: onTap,
      ),
    );
  }
}