import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_color_scheme.dart';
import '../states/sales_replacement_detail_format.dart';

/// One product line: name, barcode, unit price (+ discount when there is
/// one), quantity and line total. Shared by the sales, return and
/// replacement cards; values are `Object?` because the API mixes strings
/// and numbers. [returnedQuantity] adds a "Returned" badge (original sale
/// lines only) and is ignored when null or zero.
class SalesReplacementLineRow extends StatelessWidget {
  final String name;
  final String barcode;
  final Object? unitPrice;
  final Object? discountRate;
  final Object? discountAmount;
  final Object? quantity;
  final Object? total;
  final Object? returnedQuantity;

  const SalesReplacementLineRow({
    super.key,
    required this.name,
    required this.barcode,
    required this.unitPrice,
    required this.discountRate,
    required this.discountAmount,
    required this.quantity,
    required this.total,
    this.returnedQuantity,
  });

  static const double _qtyWidth = 40;
  static const double _amountWidth = 90;
  static const double _badgeAlpha = 0.12; // no AppSizes/AppColors token

  @override
  Widget build(BuildContext context) {
    final hasDiscount = SalesReplacementDetailFormat.isPositive(discountAmount);
    final hasReturn = SalesReplacementDetailFormat.isPositive(returnedQuantity);
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
              if (hasReturn) ...[
                const SizedBox(height: AppSizes.xs),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.sm,
                    vertical: AppSizes.xs / 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: _badgeAlpha),
                    borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                  ),
                  child: Text(
                    '${AppStrings.repdReturnedQtyLabel}: ${SalesReplacementDetailFormat.quantity(returnedQuantity)}',
                    style: const TextStyle(
                      fontSize: AppSizes.fontXs,
                      fontWeight: FontWeight.w600,
                      color: AppColors.warning,
                    ),
                  ),
                ),
              ],
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