import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';

class ChangeDueBanner extends StatelessWidget {
  final double amount;

  const ChangeDueBanner({super.key, required this.amount});

  @override
  Widget build(BuildContext context) {
    final isNegative = amount < 0;
    final color = isNegative ? AppColors.error : AppColors.success;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.sm + 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            AppStrings.changeDueLabel,
            style: TextStyle(
              color: color,
              fontSize: AppSizes.fontSm,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            '₹${amount.abs().toStringAsFixed(2)}',
            style: TextStyle(
              color: color,
              fontSize: AppSizes.fontMd,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
