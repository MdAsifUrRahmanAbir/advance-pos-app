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

  const StockItem({
    required this.id,
    required this.name,
    required this.sku,
    required this.barcode,
    required this.quantity,
    required this.status,
    required this.category,
    required this.sellingPrice,
  });
}

@immutable
class StockState {
  final bool isStocksLoading;
  final bool isLoadingMore;
  final String? errorMessage;
  final String searchQuery;
  final String selectedStatus;
  final StockFilter filter;
  final StocksModel? stocksModel;
  final List<StockItem> allItems;
  final int currentStart;
  final bool hasMore;

  const StockState({
    this.isStocksLoading = false,
    this.isLoadingMore = false,
    this.errorMessage,
    this.searchQuery = '',
    this.selectedStatus = 'all',
    this.filter = StockFilter.empty,
    this.stocksModel,
    this.allItems = const [],
    this.currentStart = 0,
    this.hasMore = true,
  });

  factory StockState.initial() => const StockState();

  StockState copyWith({
    bool? isStocksLoading,
    bool? isLoadingMore,
    String? errorMessage,
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