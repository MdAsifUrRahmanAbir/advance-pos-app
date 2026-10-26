import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_color_scheme.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/common/custom_card.dart';
import '../../../sales_replacement_detail/presentation/widgets/sales_replacement_detail_rows.dart';
import '../states/sales_replacement_add_calc.dart';

/// The products chosen in step 1 with their credit, and the total credit.
class SalesReplacementReturnSummaryCard extends StatelessWidget {
  final List<ReturnLine> lines;
  final double total;

  const SalesReplacementReturnSummaryCard({
    super.key,
    required this.lines,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.repdReturnedSectionTitle,
            style: TextStyle(
              fontSize: AppSizes.fontMd,
              fontWeight: FontWeight.w700,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSizes.sm),
          for (final line in lines)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSizes.xs / 2),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${line.quantity}× ${line.sold.name}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: AppSizes.fontSm,
                        color: colors.textPrimary,
                      ),
                    ),
                  ),
                  Text(
                    CurrencyFormatter.format(line.net),
                    style: TextStyle(
                      fontSize: AppSizes.fontSm,
                      fontWeight: FontWeight.w600,
                      color: colors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          Divider(color: colors.divider),
          SalesReplacementAmountRow(
            label: AppStrings.repdReturnAmountLabel,
            value: CurrencyFormatter.format(total),
            bold: true,
            color: AppColors.primary,
          ),
        ],
      ),
    );
  }
}