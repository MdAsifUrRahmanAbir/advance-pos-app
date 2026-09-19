import 'package:flutter/foundation.dart';
import '../../data/models/stocks_model.dart';
import 'stock_filter.dart';

enum StockStatus { inStock, lowStock, outOfStock }

@immutable
class StockItem {
  final String id;
  final String name;
  final String sku;
  final String barcode;
  final int quantity;
  final StockStatus status;
  final String category;
  final double sellingPrice;
  final String unit;
  final int lowStockThreshold;

  const StockItem({
    required this.id,
    required this.name,
    required this.sku,
    required this.barcode,
    required this.quantity,
    required this.status,
    required this.category,
    required this.sellingPrice,
    this.unit = 'pcs', // TODO: not available from the stock API yet — defaulted.
    this.lowStockThreshold = 10, // TODO: not available from the stock API yet — defaulted.
  });
}

@immutable
class StockState {
  final bool isStocksLoading;
  final bool isLoadingMore;
  final String? errorMessage;
  /// Dev-facing breakdown for the full "Technical Details" screen —
  /// built by `buildTechnicalErrorDetails()` alongside [errorMessage].
  /// Null until an error actually occurs.
  final String? technicalDetails;
  final String searchQuery;
  final String selectedStatus; // 'all' | one of StockStatus.name
  final StockFilter filter;
  final StocksModel? stocksModel;
  final List<StockItem> allItems;
  final int currentStart;
  final bool hasMore;

  const StockState({
    this.isStocksLoading = false,
    this.isLoadingMore = false,
    this.errorMessage,
    this.technicalDetails,
    this.searchQuery = '',
    this.selectedStatus = 'all',
    this.filter = StockFilter.empty,
    this.stocksModel,
    this.allItems = const [],
    this.currentStart = 0,
    this.hasMore = true,
  });

  factory StockState.initial() => const StockState();

  /// Client-side status filter over the currently-loaded page(s) — the
  /// quick "All/In Stock/Low Stock/Out of Stock" tabs. Separate from
  /// [filter] (Group/Category/Subcategory/Brand), which is applied
  /// server-side via the filter drawer. Same caveat as Invoices: since
  /// this only filters what's already loaded via infinite scroll, a
  /// status with few loaded matches may show few results until more
  /// pages load in.
  List<StockItem> get filteredItems {
    if (selectedStatus == 'all') return allItems;
    return allItems.where((item) => item.status.name == selectedStatus).toList();
  }

  StockState copyWith({
    bool? isStocksLoading,
    bool? isLoadingMore,
    String? errorMessage,
    String? technicalDetails,
    String? searchQuery,
    String? selectedStatus,
    StockFilter? filter,
    StocksModel? stocksModel,
    List<StockItem>? allItems,
    int? currentStart,
    bool? hasMore,
  }) {
    return StockState(
      isStocksLoading: isStocksLoading ?? this.isStocksLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage: errorMessage,
      technicalDetails: technicalDetails,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedStatus: selectedStatus ?? this.selectedStatus,
      filter: filter ?? this.filter,
      stocksModel: stocksModel ?? this.stocksModel,
      allItems: allItems ?? this.allItems,
      currentStart: currentStart ?? this.currentStart,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}