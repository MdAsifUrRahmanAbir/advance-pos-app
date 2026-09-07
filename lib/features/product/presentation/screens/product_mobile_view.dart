import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/common/app_header_bar.dart';
import '../../../../core/widgets/utility/empty_state.dart';
import '../../../../core/widgets/utility/error_state.dart';
import '../../../../core/widgets/utility/shimmer_extension.dart';
import '../../data/models/product_model.dart';
import '../controllers/product_controller.dart';
import '../widgets/product_card_item.dart';
import '../widgets/product_category_tabs.dart';
import '../widgets/product_search_bar.dart';

class ProductMobileView extends ConsumerWidget {
  const ProductMobileView({super.key});

  // Used only to size/shape the shimmer placeholders during first load —
  // never shown to the user as real data.
  static const _placeholderCount = 6;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(productControllerProvider);
    final controller = ref.read(productControllerProvider.notifier);

    final products = state.productModel?.resultData ?? const <ResultDatum>[];
    final isInitialLoading =
        state.isProductLoading && state.productModel == null;
    final hasError = state.errorMessage != null && state.productModel == null;

    return Column(
      children: [
        const AppHeaderBar(title: AppStrings.productsTitle, backStyle: HeaderBackStyle.chevron,),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSizes.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ProductCategoryTabs(
                  selected: state.selectedCategory,
                  onChanged: controller.selectCategory,
                ),
                const SizedBox(height: AppSizes.md),
                ProductSearchBar(
                  onChanged: controller.updateSearchQuery,
                  onFilterTap: () {
                    // TODO: open product filter options
                  },
                ),
                const SizedBox(height: AppSizes.md),
                _buildBody(
                  isInitialLoading: isInitialLoading,
                  hasError: hasError,
                  products: products,
                  errorMessage: state.errorMessage,
                  onRetry: controller.getProduct,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBody({
    required bool isInitialLoading,
    required bool hasError,
    required List<ResultDatum> products,
    required String? errorMessage,
    required VoidCallback onRetry,
  }) {
    if (hasError) {
      return Padding(
        padding: const EdgeInsets.only(top: AppSizes.xxl),
        child: ErrorState(
          message: errorMessage ?? AppStrings.errorOccurred,
          onRetry: onRetry,
        ),
      );
    }

    if (!isInitialLoading && products.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(top: AppSizes.xxl),
        child: EmptyState(
          title: 'No products found',
          message: 'Try a different search or category.',
          icon: Icons.inventory_2_outlined,
        ),
      );
    }

    final items = isInitialLoading
        ? List.generate(_placeholderCount, (_) => _placeholderCard())
        : products.map(_mapToCard).toList();

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: AppSizes.md,
      mainAxisSpacing: AppSizes.md,
      childAspectRatio: 0.65,
      children: items,
    ).skeletonizer(enabled: isInitialLoading);
  }

  ProductCardItem _mapToCard(ResultDatum item) {
    final price = double.parse(item.salePrice) ?? 0;
    print("--------------------");
    // print(item);
    print(item.salePrice);
    print(price.toStringAsFixed(2));
    print( CurrencyFormatter.format(price));
    return ProductCardItem(
      category: item.category,
      name: item.name,
      price: CurrencyFormatter.format(price),
      // TODO: wire real stock status once the API exposes it —
      // defaulting to inStock so the UI doesn't fabricate a warning state.
      stockStatus: ProductStockStatus.inStock,
    );
  }

  ProductCardItem _placeholderCard() {
    return const ProductCardItem(
      category: 'Category',
      name: 'Product name placeholder',
      price: '\$00.00',
      stockStatus: ProductStockStatus.inStock,
    );
  }
}
