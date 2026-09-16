import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_color_scheme.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../states/stock_state.dart';

/// Detail content shown in a [CustomBottomSheet] when "Show Info" is
/// tapped on a [StockCardTile] — every field on the item, plus the
/// specific reason for a low/out-of-stock/slow-moving status so a store
/// manager can act on it without opening a separate screen.
class StockDetailSheet extends StatelessWidget {
  final StockItem item;

  const StockDetailSheet({super.key, required this.item});

  String? get _statusNote {
    switch (item.status) {
      case StockStatus.lowStock:
        return 'Only ${item.quantity} {item.unit} left — below the reorder threshold of {item.lowStockThreshold} {item.unit}.';
      case StockStatus.outOfStock:
        return 'This item is currently out of stock. Restock to resume sales.';
      case StockStatus.inStock:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final note = _statusNote;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item.name,
          style: TextStyle(
            fontSize: AppSizes.fontXl,
            fontWeight: FontWeight.w700,
            color: context.appColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSizes.lg),
        _DetailRow(label: AppStrings.stockCategoryLabel, value: item.category),
        _DetailRow(label: AppStrings.stockSkuLabel, value: item.sku),
        _DetailRow(label: AppStrings.stockBarcodeLabel, value: item.barcode),
        _DetailRow(
          label: AppStrings.stockQuantityLabel,
          value: '${item.quantity} {item.unit}',
        ),
        _DetailRow(
          label: AppStrings.sellingPriceLabel,
          value: CurrencyFormatter.format(item.sellingPrice, symbol: '৳'),
        ),
        if (note != null) ...[
          const SizedBox(height: AppSizes.md),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSizes.md),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(AppSizes.radiusSm),
            ),
            child: Text(
              note,
              style: const TextStyle(
                fontSize: AppSizes.fontSm,
                color: AppColors.warning,
                height: 1.4,
              ),
            ),
          ),
        ],
        const SizedBox(height: AppSizes.sm),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

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
          Text(
            value,
            style: TextStyle(
              fontSize: AppSizes.fontSm,
              fontWeight: FontWeight.w600,
              color: context.appColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
