import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_color_scheme.dart';
import '../../../../core/widgets/common/custom_card.dart';
import '../../data/models/sales_replacement_detail_model.dart' show ResultData;
import '../states/sales_replacement_detail_format.dart';
import 'sales_replacement_detail_rows.dart';
import 'sales_replacement_line_row.dart';
import 'sales_replacement_totals_row.dart';

/// "Return Information": return bill, date and staff, the returned product
/// lines with their totals, then the discount and payable return amount.
class SalesReplacementReturnCard extends StatelessWidget {
  final ResultData data;

  const SalesReplacementReturnCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final r = data.resultDataReturn;
    final rate = r.salesDisRate?.toString().trim() ?? '';
    final discountLabel = rate.isEmpty
        ? AppStrings.invoiceDiscountLabel
        : '${AppStrings.invoiceDiscountLabel} ($rate%)';
    final hasDiscount = SalesReplacementDetailFormat.isPositive(
      r.returnDisAmount,
    );

    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.repdReturnSectionTitle,
            style: TextStyle(
              fontSize: AppSizes.fontMd,
              fontWeight: FontWeight.w700,
              color: context.appColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSizes.md),
          SalesReplacementInfoRow(
            label: AppStrings.srdReturnBillNoLabel,
            value: r.returnBillNo,
          ),
          SalesReplacementInfoRow(
            label: AppStrings.srdReturnDateLabel,
            value: r.returnDate,
          ),
          SalesReplacementInfoRow(
            label: AppStrings.srdReturnByLabel,
            value: data.returnBy,
          ),
          const SizedBox(height: AppSizes.sm),
          Divider(color: context.appColors.divider),
          const SizedBox(height: AppSizes.sm),
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
          const SizedBox(height: AppSizes.sm),
          SalesReplacementAmountRow(
            label: discountLabel,
            value:
            '${hasDiscount ? '- ' : ''}${SalesReplacementDetailFormat.money(r.returnDisAmount)}',
            color: hasDiscount ? AppColors.warning : null,
          ),
          SalesReplacementAmountRow(
            label: AppStrings.srdAfterDiscountLabel,
            value: SalesReplacementDetailFormat.money(r.taAfterDiscount),
          ),
          Divider(color: context.appColors.divider),
          SalesReplacementAmountRow(
            label: AppStrings.srdPayableLabel,
            value: SalesReplacementDetailFormat.money(r.payableReturnAmount),
            bold: true,
            color: AppColors.primary,
          ),
        ],
      ),
    );
  }
}