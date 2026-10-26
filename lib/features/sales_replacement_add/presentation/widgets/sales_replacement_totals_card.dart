import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_color_scheme.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/common/custom_card.dart';
import '../../../sales_replacement_detail/presentation/widgets/sales_replacement_detail_rows.dart';

/// Replacement items total, less the return credit, equals what the
/// customer pays. Warns when the new items don't cover the credit.
class SalesReplacementTotalsCard extends StatelessWidget {
  final double returnTotal;
  final double newTotal;
  final double netPayable;
  final bool isShortOfReturn;

  const SalesReplacementTotalsCard({
    super.key,
    required this.returnTotal,
    required this.newTotal,
    required this.netPayable,
    required this.isShortOfReturn,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SalesReplacementAmountRow(
            label: AppStrings.repaNewItemsTotalLabel,
            value: CurrencyFormatter.format(newTotal),
          ),
          SalesReplacementAmountRow(
            label: AppStrings.repdReturnAmountLabel,
            value: '- ${CurrencyFormatter.format(returnTotal)}',
            color: AppColors.warning,
          ),
          Divider(color: context.appColors.divider),
          SalesReplacementAmountRow(
            label: AppStrings.repaNetPayableLabel,
            value: CurrencyFormatter.format(netPayable < 0 ? 0 : netPayable),
            bold: true,
            color: AppColors.primary,
          ),
          if (isShortOfReturn) ...[
            const SizedBox(height: AppSizes.sm),
            Text(
              AppStrings.repaNewLessThanReturn,
              style: const TextStyle(
                fontSize: AppSizes.fontXs,
                color: AppColors.error,
              ),
            ),
          ],
        ],
      ),
    );
  }
}