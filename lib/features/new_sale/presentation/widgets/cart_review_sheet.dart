import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_color_scheme.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/common/primary_button.dart';
import '../../../../core/widgets/utility/empty_state.dart';
import '../controllers/new_sale_controller.dart';
import '../states/new_sale_state.dart';

/// Bottom sheet triggered from [CartSummaryBar.onTap] — lists every
/// [CartLineItem] currently in the cart with a quantity stepper, shows
/// the running total, and a "Next" action that hands off to the full
/// cart/checkout screen. Purely presentational except for the qty
/// mutations, which go straight through [NewSaleController] so the
/// underlying [NewSaleState.cartItems] (and therefore the badge/total on
/// [CartSummaryBar]) update live while the sheet is open.
class CartReviewSheet extends ConsumerWidget {
  final VoidCallback onNext;

  const CartReviewSheet({super.key, required this.onNext});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(newSaleControllerProvider);
    final controller = ref.read(newSaleControllerProvider.notifier);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Cart (${state.cartItemCount})',
              style: TextStyle(
                fontSize: AppSizes.fontXl,
                fontWeight: FontWeight.w700,
                color: context.appColors.textPrimary,
              ),
            ),
            IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: Icon(
                Icons.close_rounded,
                color: context.appColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.md),
        if (state.cartItems.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSizes.xl),
            child: EmptyState(
              title: 'Cart is empty',
              message: 'Add or scan a product to get started.',
              icon: Icons.shopping_cart_outlined,
            ),
          )
        else
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: state.cartItems.length,
              separatorBuilder: (_, _) => Divider(
                height: AppSizes.lg,
                color: context.appColors.divider,
              ),
              itemBuilder: (context, index) {
                final line = state.cartItems[index];
                return _CartLineRow(
                  line: line,
                  onIncrease: () => controller.increaseQty(line.product.id),
                  onDecrease: () => controller.decreaseQty(line.product.id),
                );
              },
            ),
          ),
        if (state.cartItems.isNotEmpty) ...[
          const SizedBox(height: AppSizes.lg),
          Divider(color: context.appColors.divider),
          const SizedBox(height: AppSizes.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: TextStyle(
                  fontSize: AppSizes.fontMd,
                  fontWeight: FontWeight.w600,
                  color: context.appColors.textSecondary,
                ),
              ),
              Text(
                CurrencyFormatter.format(state.cartTotal),
                style: TextStyle(
                  fontSize: AppSizes.fontXl,
                  fontWeight: FontWeight.w700,
                  color: context.appColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.lg),
          PrimaryButton(label: 'Next', onPressed: onNext),
        ],
      ],
    );
  }
}

class _CartLineRow extends StatelessWidget {
  final CartLineItem line;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;

  const _CartLineRow({
    required this.line,
    required this.onIncrease,
    required this.onDecrease,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: AppSizes.xxl,
          height: AppSizes.xxl,
          decoration: BoxDecoration(
            color: context.appColors.background,
            borderRadius: BorderRadius.circular(AppSizes.radiusSm),
          ),
          alignment: Alignment.center,
          child: Icon(
            Icons.inventory_2_outlined,
            size: AppSizes.iconSm,
            color: context.appColors.textHint,
          ),
        ),
        const SizedBox(width: AppSizes.sm + AppSizes.xs),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                line.product.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: AppSizes.fontMd,
                  fontWeight: FontWeight.w600,
                  color: context.appColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSizes.xs / 2),
              Text(
                CurrencyFormatter.format(line.product.price),
                style: TextStyle(
                  fontSize: AppSizes.fontSm,
                  color: context.appColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSizes.sm),
        _QtyStepper(
          quantity: line.quantity,
          onIncrease: onIncrease,
          onDecrease: onDecrease,
        ),
      ],
    );
  }
}

class _QtyStepper extends StatelessWidget {
  final int quantity;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;

  const _QtyStepper({
    required this.quantity,
    required this.onIncrease,
    required this.onDecrease,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.appColors.background,
        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _stepButton(icon: Icons.remove_rounded, onTap: onDecrease),
          SizedBox(
            width: AppSizes.lg,
            child: Text(
              '$quantity',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: AppSizes.fontMd,
                fontWeight: FontWeight.w700,
                color: context.appColors.textPrimary,
              ),
            ),
          ),
          _stepButton(icon: Icons.add_rounded, onTap: onIncrease),
        ],
      ),
    );
  }

  Widget _stepButton({required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.radiusFull),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.xs + AppSizes.xs / 2),
        child: Icon(icon, size: AppSizes.iconSm, color: AppColors.primary),
      ),
    );
  }
}
