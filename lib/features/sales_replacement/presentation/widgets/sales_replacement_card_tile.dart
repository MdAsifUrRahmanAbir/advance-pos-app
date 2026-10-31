import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_color_scheme.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/common/custom_card.dart';
import '../../data/models/sales_replacement_model.dart' show ResultDatum;
import 'sales_replacement_item_menu.dart';

/// One sales replacement row: bill no with the ⋮ menu, then date, original
/// sale, quantity, amount, product, customer and who did the replacement.
/// Tap opens the detail screen.
class SalesReplacementCardTile extends StatelessWidget {
  final ResultDatum item;
  final VoidCallback? onShowInfo;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onSend;
  final VoidCallback? onBillPreview;

  /// A delete or bill load for this row is running.
  final bool isBusy;

  const SalesReplacementCardTile({
    super.key,
    required this.item,
    this.onShowInfo,
    this.onEdit,
    this.onDelete,
    this.onSend,
    this.onBillPreview,
    this.isBusy = false,
  });

  @override
  Widget build(BuildContext context) {
    final extraProducts = item.productNames.length - 1;
    final firstProduct = item.productNames.isEmpty
        ? AppStrings.srNoProducts
        : item.productNames.first;
    final product = extraProducts > 0
        ? '$firstProduct  ${AppStrings.srMoreProducts(extraProducts)}'
        : firstProduct;
    final replacedBy = item.returnBy.trim().isEmpty
        ? AppStrings.repNotAvailable
        : item.returnBy;

    return CustomCard(
      onTap: isBusy ? null : onShowInfo,
      padding: const EdgeInsets.only(
        left: AppSizes.lg,
        right: AppSizes.sm,
        top: AppSizes.sm,
        bottom: AppSizes.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _Field(
                  label: AppStrings.billLabel,
                  value: item.returnBillNo,
                  emphasized: true,
                ),
              ),
              SalesReplacementItemMenu(
                isBusy: isBusy,
                onEdit: onEdit,
                onDelete: onDelete,
                onSend: onSend,
                onBillPreview: onBillPreview,
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(right: AppSizes.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _Field(
                        label: AppStrings.receiptDateLabel,
                        value: item.returnDate,
                      ),
                    ),
                    Expanded(
                      child: _Field(
                        label: AppStrings.repOriginalSalesLabel,
                        value: item.salesBillNo,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.sm),
                Row(
                  children: [
                    Expanded(
                      child: _Field(
                        label: AppStrings.repQuantityLabel,
                        value: parseQuantity(item.totalReturnQuantity).toString(),
                      ),
                    ),
                    Expanded(
                      child: _Field(
                        label: AppStrings.expAmount,
                        value: CurrencyFormatter.format(
                          parseAmount(item.totalReturnAmount),
                        ),
                        highlighted: true,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.sm),
                _Field(
                  label: AppStrings.repProductLabel,
                  value: product,
                  maxLines: 2,
                ),
                const SizedBox(height: AppSizes.sm),
                Row(
                  children: [
                    Expanded(
                      child: _Field(
                        label: AppStrings.invoiceCustomerLabel,
                        value: item.customerName,
                      ),
                    ),
                    Expanded(
                      child: _Field(
                        label: AppStrings.repReplacementByLabel,
                        value: replacedBy,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final String label;
  final String value;
  final int maxLines;
  final bool emphasized;
  final bool highlighted;

  const _Field({
    required this.label,
    required this.value,
    this.maxLines = 1,
    this.emphasized = false,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: AppSizes.fontXs, color: colors.textHint),
        ),
        const SizedBox(height: AppSizes.xs / 2),
        Text(
          value,
          maxLines: maxLines,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: emphasized ? AppSizes.fontMd : AppSizes.fontSm,
            fontWeight: emphasized || highlighted
                ? FontWeight.w700
                : FontWeight.w600,
            color: highlighted ? AppColors.primary : colors.textPrimary,
          ),
        ),
      ],
    );
  }
}