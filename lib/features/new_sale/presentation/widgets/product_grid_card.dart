import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/common/custom_card.dart';
import '../states/new_sale_state.dart';

/// Single product tile: image placeholder, name, SKU, price, add button.
/// Add button is composed inline (InkWell + circle Container) — not a new
/// core widget, since this specific circular-icon-on-price-row layout is
/// narrow to this card.
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
    return CustomCard(
      padding: const EdgeInsets.all(AppSizes.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 1.5,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(AppSizes.radiusSm),
              ),
              // TODO: wire to CustomNetworkImage(product.imageUrl) once
              // product images are served by the API.
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
            style: const TextStyle(color: AppColors.textSecondary, fontSize: AppSizes.fontXs),
          ),
          const SizedBox(height: AppSizes.xs),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '₹${product.price.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: AppSizes.fontMd,
                  fontWeight: FontWeight.w800,
                ),
              ),
              InkWell(
                onTap: onAddToCart,
                borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                child: Container(
                  padding: const EdgeInsets.all(AppSizes.xs),
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.add, size: AppSizes.iconSm, color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}