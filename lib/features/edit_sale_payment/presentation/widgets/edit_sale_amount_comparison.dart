import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_color_scheme.dart';
import '../../../../core/utils/currency_formatter.dart';

/// One line under the payable card: what the invoice was before the
/// edit (total + paid), so the salesman can see the difference.
class EditSaleAmountComparison extends StatelessWidget {
  final double originalPayable;
  final double originalPaid;
  final double newPayable;

  const EditSaleAmountComparison({
    super.key,
    required this.originalPayable,
    required this.originalPaid,
    required this.newPayable,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final difference = newPayable - originalPayable;
    final differenceColor = difference > 0
        ? AppColors.warning
        : difference < 0
        ? AppColors.success
        : colors.textSecondary;

    return Row(
      children: [
        Expanded(
          child: Text(
            '${AppStrings.editSaleOriginalTotalLabel}: '
                '${CurrencyFormatter.format(originalPayable)}  •  '
                '${AppStrings.invoicePaidLabel}: '
                '${CurrencyFormatter.format(originalPaid)}',
            style: TextStyle(color: colors.textSecondary, fontSize: AppSizes.fontXs),
          ),
        ),
        if (difference.abs() >= 0.005)
          Text(
            '${difference > 0 ? '+' : '-'}${CurrencyFormatter.format(difference.abs())}',
            style: TextStyle(
              color: differenceColor,
              fontSize: AppSizes.fontSm,
              fontWeight: FontWeight.w700,
            ),
          ),
      ],
    );
  }
}