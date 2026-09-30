import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/currency_formatter.dart';

/// Positive [amount] (with cash) = cash to hand back to the customer.
/// Negative [amount] = amount still missing.
class ChangeDueBanner extends StatelessWidget {
  final double amount;

  const ChangeDueBanner({super.key, required this.amount});

  @override
  Widget build(BuildContext context) {
    final isShort = amount < 0;
    final color = isShort ? AppColors.error : AppColors.success;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.sm + 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
      ),
      child: Row(
        children: [
          Icon(isShort ? Icons.error_outline_rounded : Icons.keyboard_return_rounded,
              color: color, size: AppSizes.iconMd),
          const SizedBox(width: AppSizes.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isShort ? AppStrings.remainingAmountLabel : AppStrings.returnToCustomerLabel,
                  style: TextStyle(color: color, fontSize: AppSizes.fontSm, fontWeight: FontWeight.w700),
                ),
                if (!isShort)
                  Text(
                    AppStrings.returnFromCashNote,
                    style: TextStyle(color: color, fontSize: AppSizes.fontXs),
                  ),
              ],
            ),
          ),
          Text(
            CurrencyFormatter.format(amount.abs()),
            style: TextStyle(color: color, fontSize: AppSizes.fontLg, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}