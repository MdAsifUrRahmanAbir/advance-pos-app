import 'package:flutter/material.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../states/new_sale_state.dart';

/// Round product image that flies from a product card to the cart badge
/// when the product is added. Falls back to the placeholder image.
class CartFlyThumbnail extends StatelessWidget {
  final ProductItem product;

  const CartFlyThumbnail({super.key, required this.product});

  /// Ring around the thumbnail — no AppSizes token, flagged.
  static const double _ringWidth = 2;

  @override
  Widget build(BuildContext context) {
    final ImageProvider image = product.imageUrl == null
        ? const AssetImage(AppAssets.placeholder2)
        : NetworkImage(product.imageUrl!);

    return DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.surface,
        border: Border.all(color: AppColors.primary, width: _ringWidth),
        image: DecorationImage(image: image, fit: BoxFit.cover),
      ),
    );
  }
}
