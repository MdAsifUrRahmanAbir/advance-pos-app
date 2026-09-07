import 'package:flutter/material.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_color_scheme.dart';
import '../../../../core/widgets/common/custom_card.dart';
import '../../../../core/widgets/common/status_badge.dart';

enum ProductStockStatus { inStock, lowStock, outOfStock }

/// Single product grid tile — image placeholder, uppercase category
/// label, name, price, and a stock-status badge.
class ProductCardItem extends StatelessWidget {
  final String category;
  final String name;
  final String price;
  final ProductStockStatus stockStatus;
  final String? imageUrl;
  final VoidCallback? onTap;

  const ProductCardItem({
    super.key,
    required this.category,
    required this.name,
    required this.price,
    required this.stockStatus,
    this.imageUrl,
    this.onTap,
  });

  (String, StatusBadgeType) get _stockDisplay {
    switch (stockStatus) {
      case ProductStockStatus.inStock:
        return ('In Stock', StatusBadgeType.success);
      case ProductStockStatus.lowStock:
        return ('Low Stock', StatusBadgeType.warning);
      case ProductStockStatus.outOfStock:
        return ('Out of Stock', StatusBadgeType.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final (stockLabel, stockType) = _stockDisplay;

    return CustomCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSizes.sm + AppSizes.xs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 1.05,
            child: Container(
              decoration: BoxDecoration(
                color: context.appColors.background,
                borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                image: imageUrl != null
                    ? DecorationImage(image: NetworkImage(imageUrl!), fit: BoxFit.cover)
                    : null,
              ),
            ),
          ),
          const SizedBox(height: AppSizes.sm + AppSizes.xs),
          Text(
            category.toUpperCase(),
            style: TextStyle(fontSize: AppSizes.fontXs, fontWeight: FontWeight.w600, color: context.appColors.textSecondary),
          ),
          const SizedBox(height: AppSizes.xs / 2),
          Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: AppSizes.fontMd, fontWeight: FontWeight.w700, color: context.appColors.textPrimary),
          ),
          const SizedBox(height: AppSizes.sm + AppSizes.xs),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  price,
                  style: TextStyle(fontSize: AppSizes.fontLg, fontWeight: FontWeight.w700, color: context.appColors.textPrimary),
                ),
              ),
              StatusBadge(text: stockLabel, type: stockType, compact: true),
            ],
          ),
        ],
      ),
    );
  }
}