import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_color_scheme.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/common/primary_button.dart';
import '../../../cart/presentation/states/cart_state.dart';

/// Totals + "Continue to Payment" for Edit Sale.
///
/// Not the cart's `CartSummarySection`, because that one's button is
/// always enabled; here it's disabled while the cart is empty, a
/// discount check is running, or the customer is still being matched.
class EditSaleSummarySection extends StatelessWidget {
  final CartState cart;
  final bool canProceed;
  final VoidCallback onProceed;

  const EditSaleSummarySection({
    super.key,
    required this.cart,
    required this.canProceed,
    required this.onProceed,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Row(
          label: AppStrings.subtotalLabel,
          value: CurrencyFormatter.format(cart.subtotal),
        ),
        _Row(
          label: AppStrings.discountPercentLabel(trimDecimal(cart.discountPercent)),
          value: '- ${CurrencyFormatter.format(cart.discountAmount)}',
          valueColor: cart.discountAmount > 0 ? AppColors.error : null,
        ),
        _Row(
          label: AppStrings.vatTaxPercentLabel(trimDecimal(cart.taxPercent)),
          value: '+ ${CurrencyFormatter.format(cart.taxAmount)}',
        ),
        Divider(height: AppSizes.lg, color: colors.border),
        Row(
          children: [
            Expanded(
              child: Text(
                AppStrings.totalPayableLabel,
                style: TextStyle(
                  color: colors.textPrimary,
                  fontSize: AppSizes.fontMd,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            if (cart.isGetDiscountLoading)
              const Padding(
                padding: EdgeInsets.only(right: AppSizes.sm),
                child: SizedBox.square(
                  dimension: AppSizes.iconSm,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            Text(
              CurrencyFormatter.format(cart.totalPayable),
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
          label: AppStrings.editSaleProceedAction,
          icon: Icons.arrow_forward_rounded,
          onPressed: canProceed ? onProceed : null,
        ),
      ],
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _Row({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.xs / 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: colors.textSecondary, fontSize: AppSizes.fontSm)),
          Text(
            value,
            style: TextStyle(
              color: valueColor ?? colors.textPrimary,
              fontSize: AppSizes.fontSm,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}