import 'package:flutter/material.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/common/custom_labeled_divider.dart';
import '../../../../core/widgets/common/secondary_button.dart';

/// "or continue with" divider + Google / Apple sign-in buttons.
class SocialLoginSection extends StatelessWidget {
  final VoidCallback? onGoogleTap;
  final VoidCallback? onAppleTap;

  const SocialLoginSection({
    super.key,
    this.onGoogleTap,
    this.onAppleTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const CustomLabeledDivider(label: AppStrings.orContinueWith),
        const SizedBox(height: AppSizes.md),
        Row(
          children: [
            Expanded(
              child: SecondaryButton(
                label: AppStrings.google,
                icon: Icons.g_mobiledata_rounded,
                onPressed: onGoogleTap,
              ),
            ),
            const SizedBox(width: AppSizes.md),
            Expanded(
              child: SecondaryButton(
                label: AppStrings.apple,
                icon: Icons.apple,
                onPressed: onAppleTap,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
