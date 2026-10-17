import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_color_scheme.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/common/custom_card.dart';
import '../../../new_sale/presentation/states/new_sale_state.dart' show ProductItem;

/// Inline results panel for the Edit Sale search bar. Each row shows how
/// many more units can still be added (branch stock + qty already on
/// this invoice − qty in the cart) and an add button that disables at 0.
class EditSaleProductResults extends StatelessWidget {
  final List<ProductItem> products;
  final bool isLoading;
  final String? errorMessage;
  final int Function(ProductItem product) remainingFor;
  final ValueChanged<ProductItem> onAdd;
  final VoidCallback onClose;
  final VoidCallback onRetry;

  const EditSaleProductResults({
    super.key,
    required this.products,
    required this.isLoading,
    required this.errorMessage,
    required this.remainingFor,
    required this.onAdd,
    required this.onClose,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return CustomCard(
      padding: const EdgeInsets.all(AppSizes.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  AppStrings.editSaleSearchResultsTitle,
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontSize: AppSizes.fontXs,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              TextButton(onPressed: onClose, child: const Text(AppStrings.editSaleCloseResults)),
            ],
          ),
          if (isLoading)
            const Padding(
              padding: EdgeInsets.all(AppSizes.md),
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            )
          else if (errorMessage != null)
            Padding(
              padding: const EdgeInsets.all(AppSizes.sm),
              child: Column(
                children: [
                  Text(
                    errorMessage!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.error, fontSize: AppSizes.fontSm),
                  ),
                  TextButton(onPressed: onRetry, child: const Text(AppStrings.retry)),
                ],
              ),
            )
          else if (products.isEmpty)
              Padding(
                padding: const EdgeInsets.all(AppSizes.md),
                child: Text(
                  AppStrings.editSaleNoProductsFound,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: colors.textHint, fontSize: AppSizes.fontSm),
                ),
              )
            else
              for (var i = 0; i < products.length; i++) ...[
                if (i > 0) Divider(height: AppSizes.sm, color: colors.divider),
                _ResultRow(
                  product: products[i],
                  remaining: remainingFor(products[i]),
                  onAdd: () => onAdd(products[i]),
                ),
              ],
        ],
      ),
    );
  }
}

class _ResultRow extends StatelessWidget {
  final ProductItem product;
  final int remaining;
  final VoidCallback onAdd;

  const _ResultRow({required this.product, required this.remaining, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final canAdd = remaining > 0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.xs),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: AppSizes.fontSm,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${AppStrings.skuLabel(product.sku)}  •  '
                      '${canAdd ? AppStrings.editSaleAvailableLabel(remaining) : AppStrings.outOfStockLabel}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: canAdd ? colors.textSecondary : AppColors.error,
                    fontSize: AppSizes.fontXs,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSizes.sm),
          Text(
            CurrencyFormatter.format(product.price),
            style: TextStyle(
              color: colors.textPrimary,
              fontSize: AppSizes.fontSm,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: AppSizes.sm),
          IconButton.filled(
            onPressed: canAdd ? onAdd : null,
            icon: const Icon(Icons.add, size: AppSizes.iconSm),
            style: IconButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.textWhite,
              disabledBackgroundColor: colors.border,
            ),
          ),
        ],
      ),
    );
  }
}