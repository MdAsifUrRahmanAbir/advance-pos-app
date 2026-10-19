import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_color_scheme.dart';
import '../../data/models/sales_return_model.dart' show ResultDatum;

/// Detail content shown in a [CustomBottomSheet] when a card is tapped:
/// every field of the return plus the full product list.
class SalesReturnDetailSheet extends StatelessWidget {
  final ResultDatum item;

  const SalesReturnDetailSheet({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final isActive = item.isActive == 1;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item.returnBillNo,
          style: TextStyle(
            fontSize: AppSizes.fontXl,
            fontWeight: FontWeight.w700,
            color: context.appColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSizes.lg),
        _DetailRow(
          label: AppStrings.srDetailSalesBill,
          value: item.salesBillNo,
        ),
        _DetailRow(label: AppStrings.srDetailDate, value: item.returnDate),
        _DetailRow(
          label: AppStrings.customerLabel,
          value: item.customerName,
        ),
        _DetailRow(label: AppStrings.srDetailReturnBy, value: item.returnBy),
        _DetailRow(
          label: AppStrings.srQuantityLabel,
          value: item.totalReturnQuantity,
        ),
        _DetailRow(
          label: AppStrings.srDetailTotalAmount,
          value: item.totalReturnAmount,
        ),
        _DetailRow(
          label: AppStrings.invoiceDiscountLabel,
          value: item.returnDisAmount,
        ),
        _DetailRow(
          label: AppStrings.srPayableLabel,
          value: item.payableReturnAmount,
          highlight: true,
        ),
        _DetailRow(
          label: AppStrings.srDetailStatus,
          value: isActive
              ? AppStrings.srStatusActive
              : AppStrings.srStatusInactive,
          valueColor: isActive ? AppColors.success : AppColors.error,
        ),
        const SizedBox(height: AppSizes.md),
        Text(
          AppStrings.productsTitle,
          style: TextStyle(
            fontSize: AppSizes.fontSm,
            color: context.appColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSizes.xs),
        if (item.productNames.isEmpty)
          Text(
            AppStrings.srNoProducts,
            style: TextStyle(
              fontSize: AppSizes.fontSm,
              color: context.appColors.textHint,
            ),
          )
        else
          for (final name in item.productNames)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSizes.xs / 2),
              child: Text(
                name,
                style: TextStyle(
                  fontSize: AppSizes.fontSm,
                  fontWeight: FontWeight.w600,
                  color: context.appColors.textPrimary,
                ),
              ),
            ),
        const SizedBox(height: AppSizes.sm),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;
  final Color? valueColor;

  const _DetailRow({
    required this.label,
    required this.value,
    this.highlight = false,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: AppSizes.xs + AppSizes.xs / 2,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: AppSizes.fontSm,
              color: context.appColors.textSecondary,
            ),
          ),
          const SizedBox(width: AppSizes.md),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: AppSizes.fontSm,
                fontWeight: FontWeight.w600,
                color:
                valueColor ??
                    (highlight
                        ? AppColors.primary
                        : context.appColors.textPrimary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}