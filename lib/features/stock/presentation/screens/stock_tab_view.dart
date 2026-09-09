// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
//
// import '../../../../core/constants/app_sizes.dart';
// import '../../../../core/constants/app_strings.dart';
// import '../../../../core/theme/app_color_scheme.dart';
// import '../../../../core/utils/currency_formatter.dart';
// import '../../../../core/widgets/common/app_header_bar.dart';
// import '../../../../core/widgets/utility/empty_state.dart';
// import '../../../../core/widgets/utility/error_state.dart';
// import '../../../../core/widgets/utility/shimmer_extension.dart';
// import '../../data/models/stock_model.dart';
// import '../controllers/stock_controller.dart';
// import '../widgets/stock_card_item.dart';
// import '../widgets/stock_category_tabs.dart';
// import '../widgets/stock_search_bar.dart';
//
// class StockTabView extends ConsumerWidget {
//   const StockTabView({super.key});
//
//   static const int _placeholderCount = 6;
//
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final state = ref.watch(stockControllerProvider);
//     final controller = ref.read(stockControllerProvider.notifier);
//
//     final products = state.stockModel?.resultData ?? const <ResultDatum>[];
//
//     final isInitialLoading =
//         state.isStockLoading && state.stockModel == null;
//
//     final hasError =
//         state.errorMessage != null && state.stockModel == null;
//
//     return Column(
//       children: [
//         const AppHeaderBar(
//           title: AppStrings.productsTitle,
//         ),
//
//         Expanded(
//           child: Center(
//             child: ConstrainedBox(
//               constraints: const BoxConstraints(
//                 maxWidth: 1100,
//               ),
//               child: SingleChildScrollView(
//                 padding: const EdgeInsets.all(AppSizes.xl),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // ─────────────────────────────────────────────
//                     // CATEGORY TABS
//                     // ─────────────────────────────────────────────
//                     StockCategoryTabs(
//                       selected: state.selectedCategory,
//                       onChanged: controller.selectCategory,
//                     ),
//
//                     const SizedBox(height: AppSizes.lg),
//
//                     // ─────────────────────────────────────────────
//                     // SEARCH
//                     // ─────────────────────────────────────────────
//                     StockSearchBar(
//                       onChanged: controller.updateSearchQuery,
//                       onScanTap: () {
//                         // TODO: open product filter options
//                       },
//                     ),
//
//                     const SizedBox(height: AppSizes.lg),
//
//                     // ─────────────────────────────────────────────
//                     // PRODUCT BODY
//                     // ─────────────────────────────────────────────
//                     _buildBody(
//                       context: context,
//                       isInitialLoading: isInitialLoading,
//                       hasError: hasError,
//                       products: products,
//                       errorMessage: state.errorMessage,
//                       selectedCategory: state.selectedCategory,
//                       searchQuery: state.searchQuery,
//                       onRetry: controller.getProduct,
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildBody({
//     required BuildContext context,
//     required bool isInitialLoading,
//     required bool hasError,
//     required List<ResultDatum> products,
//     required String? errorMessage,
//     required String selectedCategory,
//     required String searchQuery,
//     required VoidCallback onRetry,
//   }) {
//     // ─────────────────────────────────────────────
//     // ERROR
//     // ─────────────────────────────────────────────
//     if (hasError) {
//       return Padding(
//         padding: const EdgeInsets.only(
//           top: AppSizes.xxl,
//         ),
//         child: ErrorState(
//           message: errorMessage ?? AppStrings.errorOccurred,
//           onRetry: onRetry,
//         ),
//       );
//     }
//
//     // ─────────────────────────────────────────────
//     // LOADING
//     // ─────────────────────────────────────────────
//     if (isInitialLoading) {
//       final placeholders = List.generate(
//         _placeholderCount,
//             (_) => _placeholderCard(),
//       );
//
//       return GridView.count(
//         crossAxisCount: 3,
//         shrinkWrap: true,
//         physics: const NeverScrollableScrollPhysics(),
//         crossAxisSpacing: AppSizes.md,
//         mainAxisSpacing: AppSizes.md,
//         childAspectRatio: 0.72,
//         children: placeholders,
//       ).skeletonizer(
//         enabled: true,
//       );
//     }
//
//     // ─────────────────────────────────────────────
//     // FILTER PRODUCTS
//     // ─────────────────────────────────────────────
//     final filteredProducts = products.where((product) {
//       final matchesCategory =
//           selectedCategory == 'All' ||
//               product.category.toLowerCase() ==
//                   selectedCategory.toLowerCase();
//
//       final matchesSearch =
//           searchQuery.trim().isEmpty ||
//               product.name.toLowerCase().contains(
//                 searchQuery.trim().toLowerCase(),
//               );
//
//       return matchesCategory && matchesSearch;
//     }).toList();
//
//     // ─────────────────────────────────────────────
//     // EMPTY
//     // ─────────────────────────────────────────────
//     if (filteredProducts.isEmpty) {
//       return Padding(
//         padding: const EdgeInsets.only(
//           top: AppSizes.xxl,
//         ),
//         child: EmptyState(
//           title: 'No products found',
//           message: searchQuery.trim().isNotEmpty
//               ? 'Try a different search.'
//               : 'No products are available in this category.',
//           icon: Icons.inventory_2_outlined,
//         ),
//       );
//     }
//
//     // ─────────────────────────────────────────────
//     // PRODUCT GRID
//     // ─────────────────────────────────────────────
//     return Column(
//       children: [
//         GridView.builder(
//           itemCount: filteredProducts.length,
//           shrinkWrap: true,
//           physics: const NeverScrollableScrollPhysics(),
//           gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//             crossAxisCount: 3,
//             crossAxisSpacing: AppSizes.md,
//             mainAxisSpacing: AppSizes.md,
//             childAspectRatio: 0.72,
//           ),
//           itemBuilder: (context, index) {
//             return _mapToCard(filteredProducts[index]);
//           },
//         ),
//
//         const SizedBox(
//           height: AppSizes.md,
//         ),
//
//         // ─────────────────────────────────────────
//         // PRODUCT COUNT
//         // ─────────────────────────────────────────
//         Center(
//           child: Text(
//             'Showing ${filteredProducts.length} '
//                 'of ${products.length} products',
//             style: TextStyle(
//               fontSize: AppSizes.fontSm,
//               color: context.appColors.textSecondary,
//             ),
//           ),
//         ),
//       ],
//     );
//   }
//
//   // ─────────────────────────────────────────────
//   // API MODEL → PRODUCT CARD
//   // ─────────────────────────────────────────────
//   StockCardItem _mapToCard(ResultDatum item) {
//     final price = double.tryParse(item.salePrice) ?? 0;
//
//     return StockCardItem(
//       category: item.category,
//       name: item.name,
//       price: CurrencyFormatter.format(price),
//       stockStatus: ProductStockStatus.inStock,
//     );
//   }
//
//   // ─────────────────────────────────────────────
//   // SHIMMER PLACEHOLDER
//   // ─────────────────────────────────────────────
//   StockCardItem _placeholderCard() {
//     return const StockCardItem(
//       category: 'Category',
//       name: 'Product name placeholder',
//       price: '\$00.00',
//       stockStatus: ProductStockStatus.inStock,
//     );
//   }
// }



import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/common/app_header_bar.dart';
import '../../../../core/widgets/utility/custom_bottom_sheet.dart';
import '../../../../core/widgets/utility/custom_refresh_wrapper.dart';
import '../../../../core/widgets/utility/empty_state.dart';
import '../controllers/stock_controller.dart';
import '../widgets/stock_card_tile.dart';
import '../widgets/stock_detail_sheet.dart';
import '../widgets/stock_filter_tabs.dart';
import '../widgets/stock_search_bar.dart';

/// Same content as [StockMobileView], centered in a wider two-column
/// grid of cards for tablet/web viewports.
class StockTabView extends ConsumerWidget {
  const StockTabView({super.key});

  void _showInfo(BuildContext context, dynamic item) {
    CustomBottomSheet.show<void>(context, child: StockDetailSheet(item: item));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(stockControllerProvider);
    final controller = ref.read(stockControllerProvider.notifier);
    final items = state.filteredItems;

    return Column(
      children: [
        const AppHeaderBar(title: AppStrings.stockTitle),

        const SizedBox(height: AppSizes.md),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.md,
            vertical: AppSizes.sm,
          ),
          child: StockSearchBar(
            onChanged: (_) {},
            onScanTap: () {
              // TODO: open product filter options
            },
          ),
        ),

        Expanded(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(AppSizes.lg),
                    child: StockFilterTabs(selected: state.selectedStatus, onChanged: controller.selectStatus),
                  ),
                  Expanded(
                    child: items.isEmpty
                        ? EmptyState(
                      title: AppStrings.stockTitle,
                      message: AppStrings.stockEmptyMessage,
                      icon: Icons.inventory_2_outlined,
                    )
                        : CustomRefreshWrapper(
                      onRefresh: controller.refresh,
                      child: GridView.builder(
                        padding: const EdgeInsets.fromLTRB(AppSizes.lg, 0, AppSizes.lg, AppSizes.lg),
                        physics: const AlwaysScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: AppSizes.md,
                          mainAxisSpacing: AppSizes.md,
                          childAspectRatio: 1.7,
                        ),
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          final item = items[index];
                          return StockCardTile(item: item, onShowInfo: () => _showInfo(context, item));
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}