import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/widgets/utility/barcode_scanner_screen.dart';
import '../../../../core/widgets/utility/custom_bottom_sheet.dart';
import '../../../../core/widgets/utility/custom_snackbar.dart';
import '../../../../routes/route_names.dart';
import '../controllers/new_sale_controller.dart';
import '../widgets/cart_review_sheet.dart';
import '../widgets/new_sale_top_bar.dart';
import '../widgets/product_search_bar.dart';
import '../widgets/category_filter_bar.dart';
import '../widgets/product_grid.dart';
import '../widgets/cart_summary_bar.dart';

class NewSaleTabView extends ConsumerWidget {
  const NewSaleTabView({super.key});

  Future<void> _handleScanBarcode(BuildContext context, WidgetRef ref) async {
    final code = await BarcodeScannerScreen.scan(context);
    if (code == null) return;

    final match = ref
        .read(newSaleControllerProvider.notifier)
        .handleScannedCode(code);
    if (!context.mounted) return;

    if (match != null) {
      CustomSnackbar.show(context, 'Added: ${match.name}');
    } else {
      CustomSnackbar.show(
        context,
        'No product found for code $code',
        error: true,
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(newSaleControllerProvider);
    final controller = ref.read(newSaleControllerProvider.notifier);

    return Column(
      children: [
        NewSaleTopBar(
          onBack: () => context.pop(),
          onScanBarcode: () => _handleScanBarcode(context, ref),
        ),
        Expanded(
          child: Container(
            color: AppColors.background,
            child: Stack(
              children: [
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 640),
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(
                        AppSizes.lg,
                        AppSizes.lg,
                        AppSizes.lg,
                        AppSizes.xxl + AppSizes.xl,
                      ),
                      children: [
                        ProductSearchBar(
                          onChanged: controller.updateSearchQuery,
                        ),
                        const SizedBox(height: AppSizes.md),
                        CategoryFilterBar(
                          selectedCategory: state.selectedCategory,
                          onCategoryChanged: controller.selectCategory,
                        ),
                        const SizedBox(height: AppSizes.md),
                        ProductGrid(
                          products: state.filteredProducts,
                          onAddToCart: controller.addToCart,
                          crossAxisCount: 3,
                        ),
                      ],
                    ),
                  ),
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
                        CustomBottomSheet.show<void>(
                          context,
                          child: CartReviewSheet(
                            onNext: () {
                              Navigator.of(context).pop(); // close the sheet first
                              context.push(RouteNames.cart);
                            },
                          ),
                        );
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
