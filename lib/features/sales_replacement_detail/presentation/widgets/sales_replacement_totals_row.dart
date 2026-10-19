import 'package:flutter/material.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_color_scheme.dart';

/// "Total Quantity: x" on the left, "Total Amount: y" on the right.
class SalesReplacementTotalsRow extends StatelessWidget {
  final String quantity;
  final String amount;

  const SalesReplacementTotalsRow({
    super.key,
    required this.quantity,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontSize: AppSizes.fontSm,
      fontWeight: FontWeight.w700,
      color: context.appColors.textPrimary,
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '${AppStrings.invoiceTotalQuantityLabel}: $quantity',
          style: style,
        ),
        Text('${AppStrings.invoiceTotalAmountLabel}: $amount', style: style),
      ],
    );
  }
}