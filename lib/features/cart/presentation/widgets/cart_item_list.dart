import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../states/cart_state.dart';
import 'cart_item_card.dart';

class CartItemList extends StatelessWidget {
  final List<CartLineItem> items;
  final ValueChanged<String> onIncrement;
  final ValueChanged<String> onDecrement;
  final ValueChanged<String> onDelete;

  const CartItemList({
    super.key,
    required this.items,
    required this.onIncrement,
    required this.onDecrement,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ...items.map(
              (item) => Padding(
            padding: const EdgeInsets.only(bottom: AppSizes.sm),
            child: CartItemCard(
              item: item,
              onIncrement: () => onIncrement(item.id),
              onDecrement: () => onDecrement(item.id),
              onDelete: () => onDelete(item.id),
            ),
          ),
        ),
        if (items.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSizes.xs),
            child: Text(
              AppStrings.swipeToDeleteHint,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: AppSizes.fontXs),
            ),
          ),
      ],
    );
  }
}