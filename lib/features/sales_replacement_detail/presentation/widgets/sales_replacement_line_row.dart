import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_color_scheme.dart';
import '../states/sales_replacement_detail_format.dart';

/// One product line: name, barcode, unit price (+ discount when there is
/// one), quantity and line total. Shared by the returned and replacement
/// product cards; values are `Object?` because the API mixes strings and
/// numbers.
class SalesReplacementLineRow extends StatelessWidget {
  final String name;
  final String barcode;
  final Object? unitPrice;
  final Object? discountRate;
  final Object? discountAmount;
  final Object? quantity;
  final Object? total;

  const SalesReplacementLineRow({
    super.key,
    required this.name,
    required this.barcode,
    required this.unitPrice,
    required this.discountRate,
    required this.discountAmount,
    required this.quantity,
    required this.total,
  });

  static const double _qtyWidth = 40;
  static const double _amountWidth = 90;

  @override
  Widget build(BuildContext context) {
    final hasDiscount = SalesReplacementDetailFormat.isPositive(discountAmount);
    final price = SalesReplacementDetailFormat.money(unitPrice);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: TextStyle(
                  fontSize: AppSizes.fontSm,
                  fontWeight: FontWeight.w600,
                  color: context.appColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSizes.xs / 2),
              Text(
                '${AppStrings.stockBarcodeLabel}: ${barcode.isEmpty ? AppStrings.emptyValue : barcode}',
                style: TextStyle(
                  fontSize: AppSizes.fontXs,
                  color: context.appColors.textHint,
                ),
              ),
              const SizedBox(height: AppSizes.xs / 2),
              Text(
                hasDiscount
                    ? '${AppStrings.srdUnitPriceLabel}: $price  •  ${AppStrings.invoiceDiscountLabel}: $discountRate% (- ${SalesReplacementDetailFormat.money(discountAmount)})'
                    : '${AppStrings.srdUnitPriceLabel}: $price',
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
            '×${SalesReplacementDetailFormat.quantity(quantity)}',
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
            SalesReplacementDetailFormat.money(total),
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