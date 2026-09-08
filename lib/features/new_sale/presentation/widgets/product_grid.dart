import 'package:flutter/material.dart';

import '../../../../core/constants/app_sizes.dart';
import '../states/new_sale_state.dart';
import 'product_grid_card.dart';

class ProductGrid extends StatelessWidget {
  final List<ProductItem> products;
  final ValueChanged<ProductItem> onAddToCart;
  final int crossAxisCount;

  const ProductGrid({
    super.key,
    required this.products,
    required this.onAddToCart,
    this.crossAxisCount = 2,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: products.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: AppSizes.md,
        crossAxisSpacing: AppSizes.md,
        childAspectRatio: 0.9,
      ),
      itemBuilder: (context, index) {
        final product = products[index];
        return ProductGridCard(
          product: product,
          onAddToCart: () => onAddToCart(product),
        );
      },
    );
  }
}