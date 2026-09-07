import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_color_scheme.dart';

/// Spinner + "Connecting to secure servers..." status text, pinned
/// near the bottom of the splash screen.
class SplashLoadingIndicator extends StatelessWidget {
  const SplashLoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return  Column(
      children: [
        SizedBox(
          width: AppSizes.xl,
          height: AppSizes.xl,
          child: CircularProgressIndicator(strokeWidth: 3, color: AppColors.primary),
        ),
        SizedBox(height: AppSizes.md),
        Text(
          AppStrings.connectingToServers,
          style: TextStyle(fontSize: AppSizes.fontSm, color: context.appColors.textSecondary),
        ),
      ],
    );
  }
}