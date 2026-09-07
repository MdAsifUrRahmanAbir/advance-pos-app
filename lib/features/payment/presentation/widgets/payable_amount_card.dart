import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';

/// Amber-tinted, amber-bordered summary card for the payable amount.
/// Feature-local: needs a colored border + tint together, which may not
/// map cleanly onto CustomCard's params (unverified — its source wasn't
/// available). Revisit if CustomCard turns out to support this directly.
class PayableAmountCard extends StatelessWidget {
  final double amount;
  final String saleId;
  final String saleDate;

  const PayableAmountCard({
    super.key,
    required this.amount,
    required this.saleId,
    required this.saleDate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.06),
        border: Border.all(color: AppColors.warning),
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      ),
      child: Column(
        children: [
          Text(
            AppStrings.payableAmountLabel,
            style: const TextStyle(
              color: AppColors.warning,
              fontSize: AppSizes.fontXs,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: AppSizes.xs),
          Text(
            '₹${amount.toStringAsFixed(2)}',
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: AppSizes.fontDisplay - 4,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppSizes.xs),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(saleId, style: const TextStyle(color: AppColors.textSecondary, fontSize: AppSizes.fontXs)),
              const SizedBox(width: AppSizes.xs),
              Container(
                width: 4,
                height: 4,
                decoration: const BoxDecoration(color: AppColors.textSecondary, shape: BoxShape.circle),
              ),
              const SizedBox(width: AppSizes.xs),
              Text(saleDate, style: const TextStyle(color: AppColors.textSecondary, fontSize: AppSizes.fontXs)),
            ],
          ),
        ],
      ),
    );
  }
}