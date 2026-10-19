import 'package:flutter/material.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_color_scheme.dart';
import '../../../../core/widgets/common/custom_card.dart';
import '../../data/models/sales_replacement_detail_model.dart' show ResultData;
import '../states/sales_replacement_detail_format.dart';
import 'sales_replacement_line_row.dart';
import 'sales_replacement_totals_row.dart';

/// Products the customer handed back, with the returned totals row.
class SalesReplacementReturnedProductsCard extends StatelessWidget {
  final ResultData data;

  const SalesReplacementReturnedProductsCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final r = data.resultDataReturn;

    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.repdReturnedSectionTitle,
            style: TextStyle(
              fontSize: AppSizes.fontMd,
              fontWeight: FontWeight.w700,
              color: context.appColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSizes.sm + AppSizes.xs),
          if (data.returnDetails.isEmpty)
            Text(
              AppStrings.srdNoProducts,
              style: TextStyle(
                fontSize: AppSizes.fontSm,
                color: context.appColors.textHint,
              ),
            )
          else
            for (final line in data.returnDetails) ...[
              SalesReplacementLineRow(
                name: line.productName,
                barcode: line.productBarcode,
                unitPrice: line.salesPrice,
                discountRate: line.disRate,
                discountAmount: line.disAmount,
                quantity: line.quantity,
                total: line.totalAmount,
              ),
              const SizedBox(height: AppSizes.sm),
            ],
          Divider(color: context.appColors.divider),
          const SizedBox(height: AppSizes.sm),
          SalesReplacementTotalsRow(
            quantity: SalesReplacementDetailFormat.quantity(
              r.totalReturnQuantity,
            ),
            amount: SalesReplacementDetailFormat.money(r.totalReturnAmount),
          ),
        ],
      ),
    );
  }
}