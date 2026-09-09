// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../../../../core/constants/app_sizes.dart';
// import '../../../../core/constants/app_strings.dart';
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
// class StockMobileView extends ConsumerWidget {
//   const StockMobileView({super.key});
//
//   // Used only to size/shape the shimmer placeholders during first load —
//   // never shown to the user as real data.
//   static const _placeholderCount = 6;
//
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final state = ref.watch(stockControllerProvider);
//     final controller = ref.read(stockControllerProvider.notifier);
//
//     final products = state.stockModel?.resultData ?? const <ResultDatum>[];
//     final isInitialLoading =
//         state.isStockLoading && state.stockModel == null;
//     final hasError = state.errorMessage != null && state.stockModel == null;
//
//     return Column(
//       children: [
//         const AppHeaderBar(title: AppStrings.stockTitle, backStyle: HeaderBackStyle.none,),
//         Expanded(
//           child: SingleChildScrollView(
//             padding: const EdgeInsets.all(AppSizes.md),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 StockSearchBar(
//                   onChanged: controller.updateSearchQuery,
//                   onScanTap: () {
//                     // TODO: open product filter options
//                   },
//                 ),
//                 const SizedBox(height: AppSizes.md),
//                 StockCategoryTabs(
//                   selected: state.selectedCategory,
//                   onChanged: controller.selectCategory,
//                 ),
//                 const SizedBox(height: AppSizes.md),
//
//                 _buildBody(
//                   isInitialLoading: isInitialLoading,
//                   hasError: hasError,
//                   products: products,
//                   errorMessage: state.errorMessage,
//                   onRetry: controller.getProduct,
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildBody({
//     required bool isInitialLoading,
//     required bool hasError,
//     required List<ResultDatum> products,
//     required String? errorMessage,
//     required VoidCallback onRetry,
//   }) {
//     if (hasError) {
//       return Padding(
//         padding: const EdgeInsets.only(top: AppSizes.xxl),
//         child: ErrorState(
//           message: errorMessage ?? AppStrings.errorOccurred,
//           onRetry: onRetry,
//         ),
//       );
//     }
//
//     if (!isInitialLoading && products.isEmpty) {
//       return const Padding(
//         padding: EdgeInsets.only(top: AppSizes.xxl),
//         child: EmptyState(
//           title: 'No products found',
//           message: 'Try a different search or category.',
//           icon: Icons.inventory_2_outlined,
//         ),
//       );
//     }
//
//     final items = isInitialLoading
//         ? List.generate(_placeholderCount, (_) => _placeholderCard())
//         : products.map(_mapToCard).toList();
//
//     return GridView.count(
//       crossAxisCount: 2,
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),
//       crossAxisSpacing: AppSizes.md,
//       mainAxisSpacing: AppSizes.md,
//       childAspectRatio: 0.8,
//       children: items,
//     ).skeletonizer(enabled: isInitialLoading);
//   }
//
//   StockCardItem _mapToCard(ResultDatum item) {
//     final price = double.parse(item.salePrice);
//     // print("--------------------");
//     // // print(item);
//     // print(item.salePrice);
//     // print(price.toStringAsFixed(2));
//     // print( CurrencyFormatter.format(price));
//     return StockCardItem(
//       category: item.category,
//       name: item.name,
//       price: CurrencyFormatter.format(price),
//       // imageUrl: ,
//       // TODO: wire real stock status once the API exposes it —
//       // defaulting to inStock so the UI doesn't fabricate a warning state.
//       stockStatus: ProductStockStatus.inStock,
//     );
//   }
//
//   StockCardItem _placeholderCard() {
//     return const StockCardItem(
//       category: 'Category',
//       name: 'Product name placeholder',
//       price: '\$00.00',
//       stockStatus: ProductStockStatus.inStock,
//     );
//   }
// }

import 'package:advance_pos_app/core/widgets/utility/widget_padding_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/common/app_header_bar.dart';
import '../../../../core/widgets/utility/barcode_scanner_screen.dart';
import '../../../../core/widgets/utility/custom_bottom_sheet.dart';
import '../../../../core/widgets/utility/custom_refresh_wrapper.dart';
import '../../../../core/widgets/utility/custom_snackbar.dart';
import '../../../../core/widgets/utility/empty_state.dart';
import '../controllers/stock_controller.dart';
import '../widgets/stock_card_tile.dart';
import '../widgets/stock_detail_sheet.dart';
import '../widgets/stock_filter_tabs.dart';
import '../widgets/stock_search_bar.dart';

class StockMobileView extends ConsumerWidget {
  const StockMobileView({super.key});

  void _showInfo(BuildContext context, dynamic item) {
    CustomBottomSheet.show<void>(context, child: StockDetailSheet(item: item));
  }


  Future<void> _handleScanBarcode(BuildContext context, WidgetRef ref) async {
    final code = await BarcodeScannerScreen.scan(context);
    if (code == null) return;

    final match = ref.read(stockControllerProvider.notifier).handleScannedCode(code);
    if (!context.mounted) return;

    if (match != null) {
      CustomBottomSheet.show<void>(context, child: StockDetailSheet(item: match));
    } else {
      CustomSnackbar.show(context, 'Product not found.', error: true);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(stockControllerProvider);
    final controller = ref.read(stockControllerProvider.notifier);
    final items = state.filteredItems;

    return Column(
      children: [
        AppHeaderBar(
          title: AppStrings.stockTitle,
          onTrailingTap: () {},
          trailingIcon: Icons.filter_alt_sharp,
        ),
        const SizedBox(height: AppSizes.md),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.md,
            vertical: AppSizes.xs,
          ),
          child: StockSearchBar(
            onChanged: (_) {},
            onScanTap: () => _handleScanBarcode(context, ref),
          ),
        ),

        Padding(
          padding: const EdgeInsets.only(
            left: AppSizes.md,
            top: AppSizes.xs,
            bottom: AppSizes.xs,
          ),
          child: StockFilterTabs(
            selected: state.selectedStatus,
            onChanged: controller.selectStatus,
          ),
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
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.md,
                      vertical: AppSizes.sm,
                    ),
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: items.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: AppSizes.sm + AppSizes.xs),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return StockCardTile(
                        item: item,
                        onShowInfo: () => _showInfo(context, item),
                      );
                    },
                  ).paddingOnly(bottom: AppSizes.bottomNavBarHeight),
                ),
        ),
      ],
    );
  }
}
