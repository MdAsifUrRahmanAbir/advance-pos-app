import 'package:advance_pos_app/core/theme/app_color_scheme.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/common/custom_card.dart';
import '../states/new_sale_state.dart';

/// Single product tile: image, name, SKU, stock pcs, price, add button.
/// Add button disables (and dims) when [ProductItem.stock] is 0.
class ProductGridCard extends StatelessWidget {
  final ProductItem product;
  final VoidCallback onAddToCart;

  const ProductGridCard({
    super.key,
    required this.product,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    final bool isOutOfStock = product.stock <= 0;

    return CustomCard(
      padding: const EdgeInsets.all(AppSizes.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 1.7,
            child: Container(
              decoration: BoxDecoration(
                color: context.appColors.background,
                borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                image: DecorationImage(
                  image: product.imageUrl == null
                      ? AssetImage(AppAssets.placeholder2)
                      : NetworkImage(product.imageUrl!),
                  fit: BoxFit.cover
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSizes.xs),
          Text(
            product.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: AppSizes.fontSm,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            AppStrings.skuLabel(product.sku),
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: AppSizes.fontXs,
            ),
          ),
          const SizedBox(height: AppSizes.xs / 2),
          Text(
            isOutOfStock ? AppStrings.outOfStockLabel : AppStrings.stockPcsLabel(product.stock),
            style: TextStyle(
              color: isOutOfStock ? AppColors.error : AppColors.textSecondary,
              fontSize: AppSizes.fontXs,
              fontWeight: isOutOfStock ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
          const SizedBox(height: AppSizes.xs),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                CurrencyFormatter.format(product.price, ),
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: AppSizes.fontMd,
                  fontWeight: FontWeight.w800,
                ),
              ),
              InkWell(
                onTap: isOutOfStock ? null : onAddToCart,
                borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                child: Container(
                  padding: const EdgeInsets.all(AppSizes.xs),
                  decoration: BoxDecoration(
                    color: isOutOfStock ? AppColors.textHint : AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.add,
                    size: AppSizes.iconSm,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}