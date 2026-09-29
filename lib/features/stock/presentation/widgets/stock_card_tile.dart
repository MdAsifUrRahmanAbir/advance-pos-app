import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_color_scheme.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/common/custom_card.dart';
import '../states/stock_state.dart';

/// Single stock report row — name, category/SKU, barcode, a two-column
/// stock-qty/selling-price block, and a status indicator with a "Show
/// Info" action. Deliberately image-less (per design): this is a data
/// report, not a catalog browser, so the row stays dense and scannable.
class StockCardTile extends StatelessWidget {
  final StockItem item;
  final VoidCallback? onShowInfo;

  const StockCardTile({super.key, required this.item, this.onShowInfo});

  (Color, String) _statusDisplay(BuildContext context) {
    switch (item.status) {
      case StockStatus.inStock:
        return (AppColors.success, AppStrings.stockStatusInStock);
      case StockStatus.lowStock:
        return (AppColors.warning, AppStrings.stockStatusLowStock);
      case StockStatus.outOfStock:
        return (AppColors.error, AppStrings.stockStatusOutOfStock);
    }
  }

  @override
  Widget build(BuildContext context) {
    final (statusColor, statusLabel) = _statusDisplay(context);

    return CustomCard(
      onTap: onShowInfo,
      padding: EdgeInsets.only(
        left: AppSizes.lg,
        right: AppSizes.lg,
        top: AppSizes.lg,
        bottom: AppSizes.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: TextStyle(
                        fontSize: AppSizes.fontMd,
                        fontWeight: FontWeight.w700,
                        color: context.appColors.textPrimary,
                      ),
                    ),
                    // const SizedBox(height: AppSizes.xs / 2),
                    // Text(
                    //   '${item.category} • ${AppStrings.stockSkuPrefix}${item.sku}',
                    //   style: TextStyle(
                    //     fontSize: AppSizes.fontSm,
                    //     color: context.appColors.textSecondary,
                    //   ),
                    // ),
                    const SizedBox(height: AppSizes.xs / 2),
                    Text(
                      '${AppStrings.stockBarcodePrefix}${item.barcode}',
                      style: TextStyle(
                        fontSize: AppSizes.fontXs,
                        color: context.appColors.textHint,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSizes.sm),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: AppSizes.xs + AppSizes.xs / 2,
                        height: AppSizes.xs + AppSizes.xs / 2,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: statusColor,
                        ),
                      ),
                      const SizedBox(width: AppSizes.xs + AppSizes.xs / 2),
                      Text(
                        statusLabel,
                        style: TextStyle(
                          fontSize: AppSizes.fontSm,
                          fontWeight: FontWeight.w600,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.sm / 2),
                  _StatColumn(
                    label: AppStrings.stockQuantityLabel,
                    value: '${item.quantity} pcs',
                    isTable: false,
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: AppSizes.sm + AppSizes.xs),
          Divider(height: 1, color: context.appColors.divider),
          const SizedBox(height: AppSizes.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _StatColumn(
                label: AppStrings.sellingPriceLabel,
                value: CurrencyFormatter.format(item.sellingPrice, symbol: ''),
              ),

              // _StatColumn(
              //   leftAlign: false,
              //   label: AppStrings.buyingPriceLabel,
              //   value: CurrencyFormatter.format(item.buyingPrice, symbol: ''),
              // ),
              TextButton.icon(
                onPressed: onShowInfo,
                icon: const Icon(
                  Icons.info_outline_rounded,
                  size: AppSizes.iconSm,
                ),
                label: Text(AppStrings.showInfo),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.sm),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  final String label;
  final String value;
  final bool isTable, leftAlign;

  const _StatColumn({
    required this.label,
    required this.value,
    this.isTable = true,
    this.leftAlign = true,
  });

  @override
  Widget build(BuildContext context) {
    return isTable
        ? Column(
            crossAxisAlignment: leftAlign
                ? CrossAxisAlignment.start
                : CrossAxisAlignment.end,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: AppSizes.fontXs,
                  color: context.appColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSizes.xs / 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: AppSizes.fontMd,
                  fontWeight: FontWeight.w700,
                  color: context.appColors.textPrimary,
                ),
              ),
            ],
          )
        : Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: AppSizes.fontMd,
                  fontWeight: FontWeight.w700,
                  color: context.appColors.textPrimary,
                ),
              ),
            ],
          );
  }
}
