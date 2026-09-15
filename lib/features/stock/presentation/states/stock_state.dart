import '../../data/models/stocks_model.dart';
import 'package:flutter/foundation.dart';

/// Health/status of a stock line — drives the colored dot + label and
/// the filter tabs on the Stock report screen.
enum StockStatus { inStock, lowStock, outOfStock, slowMoving }

/// Presentation-layer shape until the real stock/inventory API is wired
/// via add_api_feature.py — at that point this maps from the real model.
@immutable
class StockItem {
  final String id;
  final String name;
  final String category;
  final String sku;
  final String barcode;
  final int quantity;
  final String unit; // e.g. 'pcs'
  final double sellingPrice;
  final StockStatus status;
  final int lowStockThreshold;

  const StockItem({
    required this.id,
    required this.name,
    required this.category,
    required this.sku,
    required this.barcode,
    required this.quantity,
    required this.sellingPrice,
    required this.status,
    this.unit = 'pcs',
    this.lowStockThreshold = 10,
  });
}

@immutable
class StockState {
  final bool isLoading;
  final String? errorMessage;
  final String searchQuery;
  final String selectedStatus; // 'all' | one of StockStatus.name
  final List<StockItem> allItems;
  final StocksModel? stocksModel;
  final bool isStocksLoading;

  // --- pagination additions ---
  final int currentStart;
  final bool
  isLoadingMore; // independent flag — loading page 2+, not initial fetch
  final bool hasMore; // false once recordsFiltered is fully loaded

  const StockState({
    this.isLoading = false,
    this.errorMessage,
    this.searchQuery = '',
    this.selectedStatus = 'all',
    this.allItems = const [],
    this.stocksModel,
    this.isStocksLoading = false,
    this.currentStart = 0,
    this.isLoadingMore = false,
    this.hasMore = true,
  });

  factory StockState.initial() => const StockState();

  List<StockItem> get filteredItems {
    return allItems.where((item) {
      final matchesStatus =
          selectedStatus == 'all' || item.status.name == selectedStatus;
      final matchesQuery =
          searchQuery.isEmpty ||
          item.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
          item.sku.toLowerCase().contains(searchQuery.toLowerCase()) ||
          item.barcode.contains(searchQuery);
      return matchesStatus && matchesQuery;
    }).toList();
  }

  StockState copyWith({
    bool? isLoading,
    String? errorMessage,
    String? searchQuery,
    String? selectedStatus,
    List<StockItem>? allItems,
    StocksModel? stocksModel,
    bool? isStocksLoading,
    int? currentStart,
    bool? isLoadingMore,
    bool? hasMore,
  }) {
    return StockState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedStatus: selectedStatus ?? this.selectedStatus,
      allItems: allItems ?? this.allItems,
      stocksModel: stocksModel ?? this.stocksModel,
      isStocksLoading: isStocksLoading ?? this.isStocksLoading,
      currentStart: currentStart ?? this.currentStart,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}
