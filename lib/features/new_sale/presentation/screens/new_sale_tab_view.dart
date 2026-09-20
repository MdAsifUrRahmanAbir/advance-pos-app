import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/technical_error_screen.dart';
import '../../../../core/widgets/utility/barcode_scanner_screen.dart';
import '../../../../core/widgets/utility/custom_bottom_sheet.dart';
import '../../../../core/widgets/utility/custom_refresh_wrapper.dart';
import '../../../../core/widgets/utility/custom_snackbar.dart';
import '../../../../core/widgets/utility/empty_state.dart';
import '../../../../core/widgets/utility/error_state.dart';
import '../../../../routes/route_names.dart';
import '../../../master_data/presentation/controllers/master_data_controller.dart';
import '../controllers/new_sale_controller.dart';
import '../states/new_sale_state.dart';
import '../widgets/cart_review_sheet.dart';
import '../widgets/cart_summary_bar.dart';
import '../widgets/category_filter_bar.dart';
import '../widgets/new_sale_top_bar.dart';
import '../widgets/product_grid.dart';
import '../widgets/product_grid_skeleton.dart';
import '../widgets/product_search_bar.dart';

class NewSaleTabView extends ConsumerStatefulWidget {
  const NewSaleTabView({super.key});

  @override
  ConsumerState<NewSaleTabView> createState() => _NewSaleTabViewState();
}

class _NewSaleTabViewState extends ConsumerState<NewSaleTabView> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 200) {
      ref.read(newSaleControllerProvider.notifier).loadMore();
    }
  }

  Future<void> _handleScanBarcode(BuildContext context, WidgetRef ref) async {
    final code = await BarcodeScannerScreen.scan(context);
    if (code == null) return;

    final result = await ref.read(newSaleControllerProvider.notifier).handleScannedCode(code);
    if (!context.mounted) return;

    switch (result.outcome) {
      case ScanOutcome.added:
        CustomSnackbar.show(context, AppStrings.productAddedMessage(result.product!.name));
        break;
      case ScanOutcome.outOfStock:
        CustomSnackbar.show(context, AppStrings.productOutOfStockMessage(result.product!.name), error: true);
        break;
      case ScanOutcome.notFound:
        CustomSnackbar.show(context, AppStrings.productNotFoundMessage(code), error: true);
        break;
    }
  }


  void _viewTechnicalDetails(NewSaleState state, NewSaleController controller) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TechnicalErrorScreen(
          errorDetails: state.technicalDetails ?? '',
          onRetry: () {
            Navigator.of(context).pop();
            controller.getProducts(reset: true);
          },
          onReportIssue: () {
            Clipboard.setData(ClipboardData(text: state.technicalDetails ?? ''));
            CustomSnackbar.show(context, 'Technical details copied.');
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(newSaleControllerProvider);
    final controller = ref.read(newSaleControllerProvider.notifier);
    final topCategories = ref.watch(masterDataControllerProvider).categoryData?.topCategories ?? const [];

    final isInitialLoad = state.isProductsLoading && state.allItems.isEmpty;
    final hasError = state.errorMessage != null && state.allItems.isEmpty;

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
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(AppSizes.lg, AppSizes.lg, AppSizes.lg, 0),
                          child: ProductSearchBar(
                            controller: controller.searchController,
                            onChanged: controller.updateSearchQuery,
                          ),
                        ),
                        const SizedBox(height: AppSizes.sm),
                        if (!isInitialLoad)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: AppSizes.lg),
                            child: CategoryFilterBar(
                              selectedCategoryId: state.selectedCategoryId,
                              topCategories: topCategories,
                              onCategorySelected: controller.selectCategory,
                            ),
                          ),
                        const SizedBox(height: AppSizes.sm),
                        Expanded(
                          child: hasError
                              ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: ErrorState(
                                  message: state.errorMessage!,
                                  onRetry: () => controller.getProducts(reset: true),
                                ),
                              ),
                              if (state.technicalDetails != null)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: AppSizes.lg),
                                  child: TextButton(
                                    onPressed: () => _viewTechnicalDetails(state, controller),
                                    child: const Text('View technical details'),
                                  ),
                                ),
                            ],
                          )
                              : isInitialLoad
                              ? const ProductGridSkeleton(itemCount: 9, crossAxisCount: 3)
                              : state.allItems.isEmpty
                              ? EmptyState(
                            title: AppStrings.newSaleTitle,
                            message: AppStrings.newSaleEmptyMessage,
                            icon: Icons.inventory_2_outlined,
                          )
                              : CustomRefreshWrapper(
                            onRefresh: controller.refresh,
                            child: ListView(
                              controller: _scrollController,
                              padding: const EdgeInsets.fromLTRB(
                                AppSizes.lg,
                                0,
                                AppSizes.lg,
                                AppSizes.xxl + AppSizes.xl,
                              ),
                              children: [
                                ProductGrid(
                                  products: state.filteredProducts,
                                  onAddToCart: controller.addToCart,
                                  crossAxisCount: 3,
                                ),
                                if (state.isLoadingMore)
                                  const Padding(
                                    padding: EdgeInsets.symmetric(vertical: AppSizes.md),
                                    child: Center(child: CircularProgressIndicator()),
                                  ),
                              ],
                            ),
                          ),
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
                              Navigator.of(context).pop();
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