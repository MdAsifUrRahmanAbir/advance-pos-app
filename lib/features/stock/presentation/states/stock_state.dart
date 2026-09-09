import '../../data/models/stock_model.dart';

class StockState {
  final bool isInitialLoading;
  final String? errorMessage;
  final String selectedCategory;
  final String searchQuery;
  final StockModel? stockModel;
  final bool isStockLoading;

  const StockState({
    this.selectedCategory = 'All',
    this.searchQuery = '',
    this.isInitialLoading = false,
    this.errorMessage,
    this.stockModel,
    this.isStockLoading = false,
  });

  StockState copyWith({
    String? selectedCategory,
    String? searchQuery,
    bool? isInitialLoading,
    String? errorMessage,
    StockModel? stockModel,
    bool? isStockLoading,
  }) {
    return StockState(
      selectedCategory: selectedCategory ?? this.selectedCategory,
      searchQuery: searchQuery ?? this.searchQuery,
      isInitialLoading: isInitialLoading ?? this.isInitialLoading,
      errorMessage: errorMessage,
      stockModel: stockModel ?? this.stockModel,
      isStockLoading: isStockLoading ?? this.isStockLoading,
    );
  }
}
