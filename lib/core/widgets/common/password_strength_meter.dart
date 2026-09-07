import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_sizes.dart';
import '../../theme/app_color_scheme.dart';

enum PasswordStrength { weak, fair, good, strong }

/// "Password Strength" label + 4-segment bar indicator, shown under a
/// password field while the user types.
class PasswordStrengthMeter extends StatelessWidget {
  final PasswordStrength strength;

  const PasswordStrengthMeter({super.key, required this.strength});

  int get _filledBars => switch (strength) {
    PasswordStrength.weak => 1,
    PasswordStrength.fair => 2,
    PasswordStrength.good => 3,
    PasswordStrength.strong => 4,
  };

  Color get _color => switch (strength) {
    PasswordStrength.weak => AppColors.error,
    PasswordStrength.fair => AppColors.warning,
    PasswordStrength.good => AppColors.info,
    PasswordStrength.strong => AppColors.success,
  };

  String get _label => switch (strength) {
    PasswordStrength.weak => 'Weak',
    PasswordStrength.fair => 'Medium',
    PasswordStrength.good => 'Good',
    PasswordStrength.strong => 'Strong',
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Password Strength',
              style: TextStyle(fontSize: AppSizes.fontXs, color: context.appColors.textSecondary),
            ),
            Text(
              _label,
              style: TextStyle(fontSize: AppSizes.fontXs, color: _color, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.xs),
        Row(
          children: List.generate(4, (index) {
            final filled = index < _filledBars;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: index == 3 ? 0 : AppSizes.xs),
                child: Container(
                  height: AppSizes.xs / 2,
                  decoration: BoxDecoration(
                    color: filled ? _color : AppColors.border,
                    borderRadius: BorderRadius.circular(AppSizes.radiusSm / 2),
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}