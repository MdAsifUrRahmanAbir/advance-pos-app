import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/error_mapper.dart';
import '../../data/repositories/new_sale_repository.dart';
import '../states/new_sale_state.dart';
import '../../data/models/stocks_model.dart';

final newSaleControllerProvider =
NotifierProvider.autoDispose<NewSaleController, NewSaleState>(
  NewSaleController.new,
);

class NewSaleController extends Notifier<NewSaleState> {
  late final TextEditingController searchController;

  NewSaleRepository get _repository => ref.read(newSaleRepositoryProvider);

  static const int _pageLength = 20;
  static const int _minSearchLength = 3;
  static const Duration _debounceDelay = Duration(milliseconds: 400);

  Timer? _debounce;

  @override
  NewSaleState build() {
    searchController = TextEditingController();
    ref.onDispose(() {
      searchController.dispose();
      _debounce?.cancel();
    });

    Future.microtask(getProducts);

    return NewSaleState.initial();
  }

  void updateSearchQuery(String query) {
    searchController.value = searchController.value.copyWith(
      text: query,
      selection: TextSelection.collapsed(offset: query.length),
    );
    state = state.copyWith(searchQuery: query);

    _debounce?.cancel();
    if (query.isEmpty) {
      _runSearch(query);
      return;
    }
    if (query.length < _minSearchLength) return;

    _debounce = Timer(_debounceDelay, () => _runSearch(query));
  }

  Future<void> _runSearch(String query) async {
    state = state.copyWith(searchQuery: query);
    await getProducts(reset: true);
  }

  Future<void> selectCategory(int? categoryId) async {
    state = state.copyWith(
      selectedCategoryId: categoryId,
      clearSelectedCategoryId: categoryId == null,
    );
    await getProducts(reset: true);
  }

  /// Won't add an out-of-stock product, and won't push an existing cart
  /// line's quantity past the product's available [ProductItem.stock].
  void addToCart(ProductItem product) {
    if (product.stock <= 0) return;

    final items = List<CartLineItem>.from(state.cartItems);
    final existingIndex = items.indexWhere((line) => line.product.id == product.id);

    if (existingIndex == -1) {
      items.add(CartLineItem(product: product, quantity: 1));
    } else {
      final current = items[existingIndex];
      if (current.quantity >= product.stock) return;
      items[existingIndex] = current.copyWith(quantity: current.quantity + 1);
    }

    state = state.copyWith(cartItems: items);
  }

  /// Capped at the product's available stock — won't increment past it.
  void increaseQty(String productId) {
    state = state.copyWith(
      cartItems: [
        for (final line in state.cartItems)
          if (line.product.id == productId)
            (line.quantity < line.product.stock ? line.copyWith(quantity: line.quantity + 1) : line)
          else
            line,
      ],
    );
  }

  void decreaseQty(String productId) {
    final items = <CartLineItem>[];
    for (final line in state.cartItems) {
      if (line.product.id != productId) {
        items.add(line);
        continue;
      }
      if (line.quantity > 1) items.add(line.copyWith(quantity: line.quantity - 1));
    }
    state = state.copyWith(cartItems: items);
  }

  void removeFromCart(String productId) {
    state = state.copyWith(
      cartItems: state.cartItems.where((line) => line.product.id != productId).toList(),
    );
  }


  void clearAll() {
    state = state.copyWith(
      cartItems: [],
    );
  }

  Future<ScanResult> handleScannedCode(String code) async {
    _debounce?.cancel();

    searchController.value = searchController.value.copyWith(
      text: code,
      selection: TextSelection.collapsed(offset: code.length),
    );
    state = state.copyWith(searchQuery: code);

    await getProducts(reset: true);

    final match = state.allItems.where((p) => p.barcode == code || p.sku == code).firstOrNull;

    if (match == null) {
      state = state.copyWith(errorMessage: AppStrings.productNotFoundMessage(code));
      return ScanResult(product: null, outcome: ScanOutcome.notFound);
    }

    final inCartQty =
        state.cartItems.where((l) => l.product.id == match.id).firstOrNull?.quantity ?? 0;

    if (match.stock <= 0 || inCartQty >= match.stock) {
      state = state.copyWith(errorMessage: AppStrings.productOutOfStockMessage(match.name));
      return ScanResult(product: match, outcome: ScanOutcome.outOfStock);
    }

    addToCart(match);
    state = state.copyWith(errorMessage: null);
    return ScanResult(product: match, outcome: ScanOutcome.added);
  }

  Future<void> refresh() async {
    await getProducts(reset: true);
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || state.isProductsLoading || !state.hasMore) return;

    state = state.copyWith(isLoadingMore: true, errorMessage: null, technicalDetails: null);
    try {
      final nextStart = state.currentStart + _pageLength;
      final StocksModel products = await _repository.getProducts(
        start: nextStart,
        length: _pageLength,
        search: state.searchQuery,
        categoryId: state.selectedCategoryId,
      );
      final newItems = products.resultData.map(_mapItem).toList();

      state = state.copyWith(
        isLoadingMore: false,
        productModel: products,
        allItems: [...state.allItems, ...newItems],
        currentStart: nextStart,
        hasMore: (nextStart + newItems.length) < products.recordsFiltered,
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

  Future<bool> getProducts({bool reset = false}) async {
    state = state.copyWith(
      isProductsLoading: true,
      errorMessage: null,
      technicalDetails: null,
      allItems: reset ? [] : state.allItems,
      currentStart: reset ? 0 : state.currentStart,
      hasMore: reset ? true : state.hasMore,
    );

    try {
      final products = await _repository.getProducts(
        start: 0,
        length: _pageLength,
        search: state.searchQuery,
        categoryId: state.selectedCategoryId,
      );
      final newItems = products.resultData.map(_mapItem).toList();

      state = state.copyWith(
        isProductsLoading: false,
        productModel: products,
        allItems: newItems,
        currentStart: 0,
        hasMore: newItems.length < products.recordsFiltered,
      );
      return true;
    } catch (error, stackTrace) {
      state = state.copyWith(
        isProductsLoading: false,
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

  ProductItem _mapItem(ResultDatum r) {
    final product = r.product.product;
    final stock = r.product.stock;
    final quantity = resolveBranchStock(stock, 2);

    return ProductItem(
      id: r.product.id.toString(),
      name: product.name,
      sku: product.skuCode,
      price: parseAmount(product.salePrice),
      categoryKey: 'Uncategorized', // TODO: not available from this endpoint
      stock: quantity,
      barcode: product.barcode.isNotEmpty ? product.barcode : product.sysBarcode,
    );
  }

  int resolveBranchStock(Stock stock, int branchId) {
    final branchEntry = stock.branchStock.where((b) => b.id == branchId).firstOrNull;
    if (branchEntry != null) return branchEntry.stock;
    return stock.branchStock.isNotEmpty ? stock.branchStock.first.stock : stock.organizationStock;
  }



  // ───────────────────────────────────────────────
  // GET
  // ───────────────────────────────────────────────
  Future<bool> getGetDiscount() async {
    state = state.copyWith(isGetDiscountLoading: true);
    try {
      final getDiscount = await _repository.getGetDiscount();
      state = state.copyWith(
        isGetDiscountLoading: false,
        getDiscountModel: getDiscount,
      );
      return true;
    } catch (error, stackTrace) {
      state = state.copyWith(
        isGetDiscountLoading: false,
        errorMessage: getErrorMessage(error, stackTrace),
      );
      return false;
    }
  }

}