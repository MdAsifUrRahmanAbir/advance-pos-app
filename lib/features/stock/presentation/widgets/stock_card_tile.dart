import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_color_scheme.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/common/custom_card.dart';
import '../../../../core/widgets/common/dashed_divider.dart';
import '../states/stock_state.dart';

/// Stock list card, in the same style as the invoice card:
///
///   Product name                 ● In Stock
///   Barcode: 123456
///   - - - - - - - - - - - - - - - - - - -
///   Qty                      Selling Price
///   12 pcs                          101.00
///
/// Tapping the card opens the detail sheet ([onShowInfo]).
class StockCardTile extends StatelessWidget {
  final StockItem item;
  final VoidCallback? onShowInfo;

  const StockCardTile({super.key, required this.item, this.onShowInfo});

  (Color, String) get _status {
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
    final colors = context.appColors;
    final (statusColor, statusLabel) = _status;
    final isOut = item.status == StockStatus.outOfStock;

    return CustomCard(
      onTap: onShowInfo,
      padding: const EdgeInsets.all(AppSizes.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name · status
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  item.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: AppSizes.fontMd,
                    fontWeight: FontWeight.w700,
                    color: colors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: AppSizes.sm),
              _StatusPill(color: statusColor, label: statusLabel),
            ],
          ),
          const SizedBox(height: AppSizes.xs / 2),

          // Barcode
          Text(
            '${AppStrings.stockBarcodePrefix}${item.barcode}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: AppSizes.fontSm,
              color: colors.textSecondary,
            ),
          ),

          const SizedBox(height: AppSizes.md),
          const DashedDivider(),
          const SizedBox(height: AppSizes.md),

          // Qty · selling price
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: _Figure(
                  label: AppStrings.srQuantityLabel,
                  value: AppStrings.stockPcsLabel(item.quantity),
                  valueColor: isOut ? AppColors.error : colors.textPrimary,
                  fontSize: AppSizes.fontMd,
                ),
              ),
              const SizedBox(width: AppSizes.sm),
              _Figure(
                label: AppStrings.sellingPriceLabel,
                value: CurrencyFormatter.format(item.sellingPrice, symbol: ''),
                valueColor: colors.textPrimary,
                fontSize: AppSizes.fontLg,
                alignEnd: true,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final Color color;
  final String label;

  const _StatusPill({required this.color, required this.label});

  /// FLAG: no tint token.
  static const double _tintAlpha = 0.12;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.sm,
        vertical: AppSizes.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: _tintAlpha),
        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: AppSizes.xs + AppSizes.xs / 2,
            height: AppSizes.xs + AppSizes.xs / 2,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: AppSizes.xs),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: AppSizes.fontXs,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

/// Small label over a bold value.
class _Figure extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;
  final double fontSize;
  final bool alignEnd;

  const _Figure({
    required this.label,
    required this.value,
    required this.valueColor,
    required this.fontSize,
    this.alignEnd = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
      alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: AppSizes.fontSm,
            color: context.appColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSizes.xs / 2),
        Text(
          value,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w800,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}