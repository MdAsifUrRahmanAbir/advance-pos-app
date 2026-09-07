import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_sizes.dart';

/// Row of progress dots — onboarding pager, multi-step checkout/forms.
/// The active dot stretches into a short bar; inactive dots stay round.
class CustomStepIndicator extends StatelessWidget {
  final int stepCount;
  final int currentStep;

  const CustomStepIndicator({
    super.key,
    required this.stepCount,
    required this.currentStep,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(stepCount, (index) {
        final active = index == currentStep;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: EdgeInsets.only(right: index == stepCount - 1 ? 0 : AppSizes.xs),
          height: AppSizes.sm,
          width: active ? AppSizes.lg : AppSizes.sm,
          decoration: BoxDecoration(
            color: active ? AppColors.primary : AppColors.border,
            borderRadius: BorderRadius.circular(AppSizes.xs),
          ),
        );
      }),
    );
  }
}