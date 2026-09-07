import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_sizes.dart';
import '../../theme/app_color_scheme.dart';

/// Horizontal divider with a centered label — "or continue with",
/// "or sign up with", etc.
class CustomLabeledDivider extends StatelessWidget {
  final String label;

  const CustomLabeledDivider({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: AppColors.divider, thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.sm),
          child: Text(
            label,
            style: TextStyle(fontSize: AppSizes.fontSm, color: context.appColors.textSecondary),
          ),
        ),
        Expanded(child: Divider(color: context.appColors.divider, thickness: 1)),
      ],
    );
  }
}
