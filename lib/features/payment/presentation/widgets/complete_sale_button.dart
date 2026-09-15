import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/common/primary_button.dart';

class CompleteSaleButton extends StatelessWidget {
  final bool isEnabled;
  final bool isLoading;
  final VoidCallback onPressed;

  const CompleteSaleButton({
    super.key,
    required this.isEnabled,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return PrimaryButton(
      label: AppStrings.completeSaleAction,
      onPressed: isEnabled ? onPressed : null,
      loading: isLoading,
      backgroundColor: AppColors.success,
    );
  }
}
