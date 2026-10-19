import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_color_scheme.dart';
import '../../../../core/widgets/common/custom_card.dart';
import '../../data/models/sales_return_detail_model.dart';
import '../states/sales_return_detail_format.dart';

/// Returned product lines with the totals row.
class SalesReturnProductsCard extends StatelessWidget {
  final SalesReturnDetailData data;

  const SalesReturnProductsCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final r = data.returnInfo;

    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.productsTitle,
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
              _LineRow(line: line),
              const SizedBox(height: AppSizes.sm),
            ],
          Divider(color: context.appColors.divider),
          const SizedBox(height: AppSizes.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${AppStrings.invoiceTotalQuantityLabel}: ${SalesReturnDetailFormat.quantity(r.totalReturnQuantity)}',
                style: TextStyle(
                  fontSize: AppSizes.fontSm,
                  fontWeight: FontWeight.w700,
                  color: context.appColors.textPrimary,
                ),
              ),
              Text(
                '${AppStrings.invoiceTotalAmountLabel}: ${SalesReturnDetailFormat.money(r.totalReturnAmount)}',
                style: TextStyle(
                  fontSize: AppSizes.fontSm,
                  fontWeight: FontWeight.w700,
                  color: context.appColors.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LineRow extends StatelessWidget {
  final SalesReturnLine line;

  const _LineRow({required this.line});

  static const double _qtyWidth = 40;
  static const double _amountWidth = 90;

  @override
  Widget build(BuildContext context) {
    final hasDiscount = SalesReturnDetailFormat.isPositive(line.disAmount);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                line.productName,
                style: TextStyle(
                  fontSize: AppSizes.fontSm,
                  fontWeight: FontWeight.w600,
                  color: context.appColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSizes.xs / 2),
              Text(
                '${AppStrings.stockBarcodeLabel}: ${line.productBarcode.isEmpty ? AppStrings.emptyValue : line.productBarcode}',
                style: TextStyle(
                  fontSize: AppSizes.fontXs,
                  color: context.appColors.textHint,
                ),
              ),
              const SizedBox(height: AppSizes.xs / 2),
              Text(
                hasDiscount
                    ? '${AppStrings.srdUnitPriceLabel}: ${SalesReturnDetailFormat.money(line.salesPrice)}  •  ${AppStrings.invoiceDiscountLabel}: ${line.disRate}% (- ${SalesReturnDetailFormat.money(line.disAmount)})'
                    : '${AppStrings.srdUnitPriceLabel}: ${SalesReturnDetailFormat.money(line.salesPrice)}',
                style: TextStyle(
                  fontSize: AppSizes.fontXs,
                  color: hasDiscount
                      ? AppColors.warning
                      : context.appColors.textHint,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          width: _qtyWidth,
          child: Text(
            '×${SalesReturnDetailFormat.quantity(line.quantity)}',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: AppSizes.fontSm,
              color: context.appColors.textSecondary,
            ),
          ),
        ),
        SizedBox(
          width: _amountWidth,
          child: Text(
            SalesReturnDetailFormat.money(line.totalAmount),
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: AppSizes.fontSm,
              fontWeight: FontWeight.w700,
              color: context.appColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}