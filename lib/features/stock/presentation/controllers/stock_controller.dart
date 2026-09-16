import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/error_mapper.dart';
import '../../data/models/stocks_model.dart';
import '../../data/repositories/stock_repository.dart';
import '../states/stock_filter.dart';
import '../states/stock_state.dart';

final stockControllerProvider =
    NotifierProvider.autoDispose<StockController, StockState>(
      StockController.new,
    );

class StockController extends Notifier<StockState> {
  late final TextEditingController searchController;

  StockRepository get _repository => ref.read(stockRepositoryProvider);

  static const int _pageLength = 15;

  @override
  StockState build() {
    searchController = TextEditingController();
    ref.onDispose(() => searchController.dispose());

    Future.microtask(getStocks);

    return StockState.initial();
  }

  void selectStatus(String statusKey) {
    state = state.copyWith(selectedStatus: statusKey);
  }

  void updateSearchQuery(String query) {
    searchController.value = searchController.value.copyWith(
      text: query,
      selection: TextSelection.collapsed(offset: query.length),
    );
    state = state.copyWith(searchQuery: query);
  }

  /// Applied by [StockFilterDrawer]'s "Apply" button — replaces the
  /// active filter and refetches from scratch.
  Future<void> applyFilter(StockFilter filter) async {
    state = state.copyWith(filter: filter);
    await getStocks(reset: true);
  }

  Future<void> clearFilter() async {
    state = state.copyWith(filter: StockFilter.empty);
    await getStocks(reset: true);
  }

  /// Pull-to-refresh: resets pagination and refetches from start=0.
  Future<void> refresh() async {
    await getStocks(reset: true);
  }

  /// Infinite-scroll continuation: fetches the next page and appends.
  /// No-op if already loading or no more pages exist — call this from
  /// a ScrollController listener near the list's bottom edge.
  Future<void> loadMore() async {
    if (state.isLoadingMore || state.isStocksLoading || !state.hasMore) return;

    state = state.copyWith(isLoadingMore: true, errorMessage: null);
    try {
      final nextStart = state.currentStart + _pageLength;
      final stocks = await _repository.getStocks(
        start: nextStart,
        length: _pageLength,
        search: state.searchQuery,
        supplierId: state.filter.supplierId,
        groupId: state.filter.groupId,
        categoryId: state.filter.categoryId,
        subCategoryId: state.filter.subCategoryId,
        brandId: state.filter.brandId,
      );
      final newItems = _mapToStockItems(stocks);
      state = state.copyWith(
        isLoadingMore: false,
        stocksModel: stocks,
        allItems: [...state.allItems, ...newItems],
        currentStart: nextStart,
        hasMore: (nextStart + newItems.length) < stocks.recordsFiltered,
      );
    } catch (error, stackTrace) {
      state = state.copyWith(
        isLoadingMore: false,
        errorMessage: getErrorMessage(error, stackTrace),
      );
    }
  }

  StockItem? handleScannedCode(String code) {
    final match = state.allItems
        .where((item) => item.barcode == code || item.sku == code)
        .firstOrNull;

    updateSearchQuery(code);
    state = state.copyWith(
      errorMessage: match == null ? 'Product not found.' : null,
    );

    return match;
  }

  // ───────────────────────────────────────────────
  // GET (initial load or full reset)
  // ───────────────────────────────────────────────
  /// [reset] clears existing items and refetches from start=0 — used by
  /// both the initial build() call, pull-to-refresh, and filter changes.
  Future<bool> getStocks({bool reset = false}) async {
    state = state.copyWith(
      isStocksLoading: true,
      errorMessage: null,
      allItems: reset ? [] : state.allItems,
      currentStart: reset ? 0 : state.currentStart,
      hasMore: reset ? true : state.hasMore,
    );

    try {
      final stocks = await _repository.getStocks(
        start: 0,
        length: _pageLength,
        search: state.searchQuery,
        supplierId: state.filter.supplierId,
        groupId: state.filter.groupId,
        categoryId: state.filter.categoryId,
        subCategoryId: state.filter.subCategoryId,
        brandId: state.filter.brandId,
      );

      final newItems = _mapToStockItems(stocks);

      state = state.copyWith(
        isStocksLoading: false,
        stocksModel: stocks,
        allItems: newItems,
        currentStart: 0,
        hasMore: newItems.length < stocks.recordsFiltered,
      );
      return true;
    } catch (error, stackTrace) {
      state = state.copyWith(
        isStocksLoading: false,
        errorMessage: getErrorMessage(error, stackTrace),
      );
      return false;
    }
  }

  List<StockItem> _mapToStockItems(StocksModel stocks) {
    return stocks.resultData.map((result) {
      final product = result.product.product;
      final stock = result.product.stock;
      final quantity = stock.organizationStock;

      return StockItem(
        id: result.product.id.toString(),
        name: product.name,
        sku: product.skuCode,
        barcode: product.barcode.isNotEmpty
            ? product.barcode
            : product.sysBarcode,
        quantity: quantity,
        status: _mapStatus(quantity, null),
        category: 'Uncategorized', // TODO: not available from this endpoint
        sellingPrice: 0.0, // TODO: not available from this endpoint
      );
    }).toList();
  }

  StockStatus _mapStatus(int quantity, int? lowStockThreshold) {
    if (quantity <= 0) return StockStatus.outOfStock;
    if (lowStockThreshold != null && quantity <= lowStockThreshold) {
      return StockStatus.lowStock;
    }
    return StockStatus.inStock;
  }
}
