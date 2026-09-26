import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/api_endpoints.dart';
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
  static const int _minSearchLength = 4;
  static const Duration _debounceDelay = Duration(milliseconds: 400);

  Timer? _debounce;

  @override
  StockState build() {
    searchController = TextEditingController();
    ref.onDispose(() {
      searchController.dispose();
      _debounce?.cancel();
    });

    Future.microtask(getStocks);

    return StockState.initial();
  }

  void selectStatus(String statusKey) {
    state = state.copyWith(selectedStatus: statusKey);
  }

  /// Called on every keystroke in [StockSearchBar]. Updates the field's
  /// displayed text immediately, but only actually hits the API once
  /// the user has typed at least [_minSearchLength] characters (or
  /// cleared the field back to empty, which resets to the unfiltered
  /// list) — debounced so a fast typist doesn't fire a request per
  /// keystroke. 1–3 characters are held locally with no request; the
  /// previously-fetched results stay on screen until either 0 or 4+ is
  /// reached.
  void updateSearchQuery(String query) {
    searchController.value = searchController.value.copyWith(
      text: query,
      selection: TextSelection.collapsed(offset: query.length),
    );
    state = state.copyWith(searchQuery: query);

    _debounce?.cancel();
    if (query.isEmpty) {
      // Reset immediately — no need to wait out the debounce for a
      // clear action, and there's nothing to type-ahead debounce against.
      _runSearch(query);
      return;
    }
    if (query.length < _minSearchLength) return;

    _debounce = Timer(_debounceDelay, () => _runSearch(query));
  }

  /// A text/barcode search and the Group/Category/Subcategory/Brand
  /// drawer filter are two different, mutually-exclusive ways of
  /// narrowing the list — running a search clears any active drawer
  /// filter so the two don't silently combine into a query the user
  /// never asked for.
  Future<void> _runSearch(String query) async {
    state = state.copyWith(searchQuery: query, filter: StockFilter.empty);
    await getStocks(reset: true);
  }

  /// Applied by [StockFilterDrawer]'s "Apply" button — replaces the
  /// active filter and refetches from scratch. Also clears any pending
  /// search so a stale debounce timer can't fire and clobber the
  /// filter right after it's applied.
  Future<void> applyFilter(StockFilter filter) async {
    _debounce?.cancel();
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

    state = state.copyWith(isLoadingMore: true, errorMessage: null, technicalDetails: null);
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
        technicalDetails: buildTechnicalErrorDetails(
          error,
          stackTrace,
          endpoint: ApiEndpoints.stocks(branchId: 2),
        ),
      );
    }
  }

  /// Scanning a barcode always hits the API immediately — unlike typed
  /// search, there's no 4-character minimum or debounce, since a scan
  /// is a single deliberate action rather than in-progress typing. Also
  /// resets any active drawer filter, same as a text search. Returns
  /// the matched item (from the freshly-fetched results) so the caller
  /// can open its detail sheet, or `null` if nothing matched.
  Future<StockItem?> handleScannedCode(String code) async {
    _debounce?.cancel();

    searchController.value = searchController.value.copyWith(
      text: code,
      selection: TextSelection.collapsed(offset: code.length),
    );
    state = state.copyWith(searchQuery: code, filter: StockFilter.empty);

    await getStocks(reset: true);

    final match = state.allItems
        .where((item) => item.barcode == code || item.sku == code)
        .firstOrNull;

    state = state.copyWith(
      errorMessage: match == null ? 'Product not found.' : null,
    );

    return match;
  }

  // ───────────────────────────────────────────────
  // GET (initial load or full reset)
  // ───────────────────────────────────────────────
  /// [reset] clears existing items and refetches from start=0 — used by
  /// both the initial build() call, pull-to-refresh, and filter/search
  /// changes.
  Future<bool> getStocks({bool reset = false}) async {
    state = state.copyWith(
      isStocksLoading: true,
      errorMessage: null,
      technicalDetails: null,
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
        technicalDetails: buildTechnicalErrorDetails(
          error,
          stackTrace,
          endpoint: ApiEndpoints.stocks(branchId: 2),
        ),
      );
      return false;
    }
  }

  List<StockItem> _mapToStockItems(StocksModel stocks) {
    const int branchId = 2; // matches ApiEndpoints.stocks(branchId: 2)

    return stocks.resultData.map((result) {
      final product = result.product.product;
      final stock = result.product.stock;
      final quantity = _resolveQuantity(stock, branchId);

      return StockItem(
        id: result.product.id.toString(),
        name: product.name,
        sku: product.skuCode,
        barcode: product.barcode.isNotEmpty
            ? product.barcode
            : product.sysBarcode,
        quantity: quantity,
        status: _mapStatus(quantity),
        category: 'Uncategorized', // TODO: not available from this endpoint
        sellingPrice: double.parse(product.salePrice),
        buyingPrice: double.parse(product.costPrice),
      );
    }).toList();
  }

  /// Picks the stock figure for the specific branch actually being
  /// queried ([branchId]) instead of `branchStock.first` — `branch_stock`
  /// isn't guaranteed ordered by branch id, so blindly taking the first
  /// entry can silently return a *different* branch's (possibly zero)
  /// stock, which is the "shows 0 pcs" bug. Falls back to
  /// [Stock.organizationStock] only as a last resort, if that branch
  /// isn't present in the array at all.
  int _resolveQuantity(Stock stock, int branchId) {
    final branchEntry = stock.branchStock.where((b) => b.id == branchId).firstOrNull;
    if (branchEntry != null) return branchEntry.stock;
    return stock.branchStock.isNotEmpty ? stock.branchStock.first.stock : stock.organizationStock;
  }


  StockStatus _mapStatus(int quantity) {
    // Low Stock removed — there's no real reorder-threshold field from
    // the stock API to compare against, so only these two statuses are
    // ever actually correct given the data we receive.
    return quantity <= 0 ? StockStatus.outOfStock : StockStatus.inStock;
  }
}