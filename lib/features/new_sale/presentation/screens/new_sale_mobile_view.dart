import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../routes/route_names.dart';
import '../controllers/new_sale_controller.dart';
import '../widgets/new_sale_top_bar.dart';
import '../widgets/product_search_bar.dart';
import '../widgets/category_filter_bar.dart';
import '../widgets/product_grid.dart';
import '../widgets/cart_summary_bar.dart';

class NewSaleMobileView extends ConsumerWidget {
  const NewSaleMobileView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(newSaleControllerProvider);
    final controller = ref.read(newSaleControllerProvider.notifier);

    return Column(
      children: [
        NewSaleTopBar(
          onBack: () => context.pop(),
          onScanBarcode: () {
            // TODO: wire barcode scanner
          },
        ),
        Expanded(
          child: Container(
            color: AppColors.background,
            child: Stack(
              children: [
                ListView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSizes.md,
                    AppSizes.md,
                    AppSizes.md,
                    AppSizes.xxl + AppSizes.xl,
                  ),
                  children: [
                    ProductSearchBar(onChanged: controller.updateSearchQuery),
                    const SizedBox(height: AppSizes.md),
                    CategoryFilterBar(
                      selectedCategory: state.selectedCategory,
                      onCategoryChanged: controller.selectCategory,
                    ),
                    const SizedBox(height: AppSizes.md),
                    ProductGrid(
                      products: state.filteredProducts,
                      onAddToCart: controller.addToCart,
                    ),
                  ],
                ),
                if (state.cartItemCount > 0)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: CartSummaryBar(
                      itemCount: state.cartItemCount,
                      total: state.cartTotal,
                      onTap: () {
                        context.push(RouteNames.cart);
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
