import 'package:flutter/material.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/widgets/utility/shimmer_extension.dart';
import '../states/new_sale_state.dart';
import 'product_grid_card.dart';

class ProductGridSkeleton extends StatelessWidget {
  final int itemCount;
  final int crossAxisCount;

  const ProductGridSkeleton({super.key, required this.itemCount, this.crossAxisCount = 2});

  static const _placeholder = ProductItem(
    id: 'skeleton',
    name: 'Sample Product Name',
    sku: 'SKU-0000',
    price: 0,
    categoryKey: 'Category',
    stock: 10,
  );

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: AppSizes.md,
        crossAxisSpacing: AppSizes.md,
        childAspectRatio: 0.9,
      ),
      itemBuilder: (context, index) => ProductGridCard(product: _placeholder, onAddToCart: () {}),
    ).skeletonizer(enabled: true);
  }
}