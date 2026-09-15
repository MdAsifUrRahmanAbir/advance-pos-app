import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';

/// ⚠️ Not wired to PrimaryInputField — its exact constructor (controller vs
/// value/onChanged, decoration params) wasn't available, and this field
/// needs a trailing numpad-icon affordance that may not be a supported
/// PrimaryInputField variant. Built as a minimal TextField composition
/// styled to match. Swap to PrimaryInputField once its source is shared,
/// if it covers a numeric-keypad-trailing-icon variant.
class GivenAmountField extends StatelessWidget {
  final double amount;
  final ValueChanged<double> onChanged;
  final VoidCallback? onOpenKeypad;

  const GivenAmountField({
    super.key,
    required this.amount,
    required this.onChanged,
    this.onOpenKeypad,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.givenAmountLabel,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: AppSizes.fontXs,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.4,
          ),
        ),
        const SizedBox(height: AppSizes.xs),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.md,
            vertical: AppSizes.sm + 4,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(AppSizes.radiusSm),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: TextField(
                  controller: TextEditingController(
                    text: amount.toStringAsFixed(2),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: AppSizes.fontXl,
                    fontWeight: FontWeight.w700,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    prefixText: '₹',
                  ),
                  onChanged: (value) => onChanged(double.tryParse(value) ?? 0),
                ),
              ),
              InkWell(
                onTap: onOpenKeypad,
                child: const Icon(
                  Icons.dialpad_rounded,
                  size: AppSizes.iconMd,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
