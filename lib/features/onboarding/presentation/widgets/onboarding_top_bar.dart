import 'package:flutter/material.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/common/link_button.dart';

/// Top-left "Skip" action shown above the onboarding carousel.
class OnboardingTopBar extends StatelessWidget {
  final VoidCallback? onSkip;

  const OnboardingTopBar({super.key, this.onSkip});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: LinkButton(
        label: AppStrings.skip,
        onPressed: onSkip,
      ),
    );
  }
}