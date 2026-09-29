import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/common/primary_button.dart';
import '../states/cart_state.dart';

class CartSummarySection extends StatelessWidget {
  final CartState state;
  final VoidCallback onProceedToPayment;

  const CartSummarySection({
    super.key,
    required this.state,
    required this.onProceedToPayment,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SummaryRow(
          label: AppStrings.subtotalLabel,
          value: '৳${state.subtotal.toStringAsFixed(2)}',
        ),
        _SummaryRow(
          label: AppStrings.discountPercentLabel(trimDecimal(state.discountPercent)),
          value: '-৳${state.discountAmount.toStringAsFixed(2)}',
          valueColor: state.discountAmount > 0 ? AppColors.error : null,
        ),
        _SummaryRow(
          label: AppStrings.vatTaxPercentLabel(trimDecimal(state.taxPercent)),
          value: '+৳${state.taxAmount.toStringAsFixed(2)}',
        ),
        if (state.rounding != 0)
          _SummaryRow(
            label: AppStrings.roundingLabel,
            value: '${state.rounding < 0 ? '-' : '+'}৳${state.rounding.abs().toStringAsFixed(2)}',
            muted: true,
          ),
        const Divider(height: AppSizes.lg, color: AppColors.border),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              AppStrings.totalPayableLabel,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: AppSizes.fontMd,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              '৳${state.totalPayable.toStringAsFixed(2)}',
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: AppSizes.fontXl,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.md),
        PrimaryButton(
          label: AppStrings.proceedToPaymentAction,
          onPressed: onProceedToPayment,
        ),
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool muted;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.muted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.xs / 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: AppSizes.fontSm,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: valueColor ?? (muted ? AppColors.textSecondary : AppColors.textPrimary),
              fontSize: AppSizes.fontSm,
              fontWeight: muted ? FontWeight.w400 : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}