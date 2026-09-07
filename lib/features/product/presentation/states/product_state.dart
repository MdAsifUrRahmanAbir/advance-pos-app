import '../../data/models/product_model.dart';

class ProductState {
  final bool isInitialLoading;
  final String? errorMessage;
  final String selectedCategory;
  final String searchQuery;
  final ProductModel? productModel;
  final bool isProductLoading;

  const ProductState({
    this.selectedCategory = 'All',
    this.searchQuery = '',
    this.isInitialLoading = false,
    this.errorMessage,
    this.productModel,
    this.isProductLoading = false,
  });

  ProductState copyWith({
    String? selectedCategory,
    String? searchQuery,
    bool? isInitialLoading,
    String? errorMessage,
    ProductModel? productModel,
    bool? isProductLoading,
  }) {
    return ProductState(
      selectedCategory: selectedCategory ?? this.selectedCategory,
      searchQuery: searchQuery ?? this.searchQuery,
      isInitialLoading: isInitialLoading ?? this.isInitialLoading,
      errorMessage: errorMessage,
      productModel: productModel ?? this.productModel,
      isProductLoading: isProductLoading ?? this.isProductLoading,
    );
  }
}
