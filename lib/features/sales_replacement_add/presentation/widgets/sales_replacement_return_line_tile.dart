import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_color_scheme.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/common/custom_card.dart';
import '../../../cart/presentation/widgets/quantity_stepper.dart';
import '../states/sales_replacement_add_calc.dart';

/// One product of the original sale. Tap to mark it as returned; a
/// quantity stepper (capped at the quantity sold) appears once selected.
class SalesReplacementReturnLineTile extends StatelessWidget {
  final SoldLine line;
  final int returnQty;
  final VoidCallback onToggle;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const SalesReplacementReturnLineTile({
    super.key,
    required this.line,
    required this.returnQty,
    required this.onToggle,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final selected = returnQty > 0;
    final hasDiscount = line.discountRate > 0;

    return CustomCard(
      onTap: onToggle,
      tinted: selected,
      padding: const EdgeInsets.all(AppSizes.md),
      child: Row(
        children: [
          Icon(
            selected
                ? Icons.check_circle_rounded
                : Icons.radio_button_unchecked_rounded,
            size: AppSizes.iconMd,
            color: selected ? AppColors.primary : colors.textHint,
          ),
          const SizedBox(width: AppSizes.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  line.name,
                  style: TextStyle(
                    fontSize: AppSizes.fontSm,
                    fontWeight: FontWeight.w600,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSizes.xs / 2),
                Text(
                  '${CurrencyFormatter.format(line.unitPrice)}  •  ${AppStrings.repaSoldQtyLabel(line.soldQty)}',
                  style: TextStyle(
                    fontSize: AppSizes.fontXs,
                    color: colors.textHint,
                  ),
                ),
                if (hasDiscount)
                  Text(
                    '${AppStrings.invoiceDiscountLabel}: ${line.discountRate.toStringAsFixed(2)}%',
                    style: const TextStyle(
                      fontSize: AppSizes.fontXs,
                      color: AppColors.warning,
                    ),
                  ),
              ],
            ),
          ),
          if (selected) ...[
            const SizedBox(width: AppSizes.sm),
            QuantityStepper(
              quantity: returnQty,
              onIncrement: onIncrement,
              onDecrement: onDecrement,
            ),
          ],
        ],
      ),
    );
  }
}