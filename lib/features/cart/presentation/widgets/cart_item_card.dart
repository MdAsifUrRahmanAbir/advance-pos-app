import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/common/custom_card.dart';
import '../states/cart_state.dart';
import 'quantity_stepper.dart';

/// Swipeable cart line item. Wraps CustomCard in a Dismissible for
/// swipe-left-to-delete (Figma hint text: "Swipe left on any item to
/// delete") — Dismissible is a Flutter built-in, not a core-widget concern.
class CartItemCard extends StatelessWidget {
  final CartLineItem item;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onDelete;
  final double discountAmount;

  const CartItemCard({
    super.key,
    required this.item,
    required this.onIncrement,
    required this.onDecrement,
    required this.onDelete,
    this.discountAmount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        ),
        child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
      ),
      onDismissed: (_) => onDelete(),
      child: CustomCard(
        padding: const EdgeInsets.all(AppSizes.md - 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: AppSizes.fontMd - 1,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    AppStrings.eachPriceLabel(
                      CurrencyFormatter.format(item.unitPrice),
                    ),
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: AppSizes.fontSm,
                    ),
                  ),
                  if (discountAmount > 0)
                    Text(
                      AppStrings.lineDiscountLabel(
                        CurrencyFormatter.format(discountAmount),
                      ),
                      style: const TextStyle(
                        color: AppColors.success,
                        fontSize: AppSizes.fontXs,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: AppSizes.md),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                QuantityStepper(
                  quantity: item.quantity,
                  onIncrement: onIncrement,
                  onDecrement: onDecrement,
                ),
                const SizedBox(width: AppSizes.md),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (discountAmount > 0)
                      Text(
                        CurrencyFormatter.format(item.lineTotal),
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: AppSizes.fontXs,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    Text(
                      CurrencyFormatter.format(item.lineTotal - discountAmount),
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: AppSizes.fontMd - 1,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
