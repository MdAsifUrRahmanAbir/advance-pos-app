import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../states/stock_state.dart';

final stockControllerProvider =
NotifierProvider.autoDispose<StockController, StockState>(StockController.new);

class StockController extends Notifier<StockState> {
  late final TextEditingController searchController;

  @override
  StockState build() {
    searchController = TextEditingController();
    ref.onDispose(() => searchController.dispose());

    // TODO: wire to stockRepositoryProvider.getStockReport() once the
    // stock/data/repositories layer is ready. Currently mock data.
    return StockState.initial().copyWith(allItems: _mockItems);
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

  Future<void> refresh() async {
    // TODO: replace with a real repository re-fetch.
    state = state.copyWith(allItems: _mockItems);
  }

  /// Resolves a scanned barcode against [StockState.allItems] — no
  /// separate repository call needed just to resolve a scanned code.
  /// Fills [searchController]/`searchQuery` with the raw code either
  /// way (which also narrows [StockState.filteredItems] down to the
  /// match, if any), and sets [StockState.errorMessage] to exactly
  /// "Product not found." on a miss. Unlike New Sale, a match here is
  /// NOT added to a cart — Stock is a report screen, so the caller is
  /// expected to show the matched item's info (e.g. open
  /// [StockDetailSheet]) rather than perform a sale action.
  StockItem? handleScannedCode(String code) {
    final match = state.allItems
        .where((item) => item.barcode == code || item.sku == code)
        .firstOrNull;

    updateSearchQuery(code);
    state = state.copyWith(errorMessage: match == null ? 'Product not found.' : null);

    return match;
  }

  static const _mockItems = [
    StockItem(
      id: 's1',
      name: 'Winner Men Shirt',
      category: 'Clothing',
      sku: 'CL-001',
      barcode: '8901030111111',
      quantity: 12,
      sellingPrice: 860.00,
      status: StockStatus.inStock,
    ),
    StockItem(
      id: 's2',
      name: 'Classic Denim Jeans',
      category: 'Clothing',
      sku: 'CL-014',
      barcode: '8901030111128',
      quantity: 4,
      sellingPrice: 1450.00,
      status: StockStatus.lowStock,
      lowStockThreshold: 8,
    ),
    StockItem(
      id: 's3',
      name: 'Fresh Milk 1L',
      category: 'Grocery',
      sku: 'MK-1002',
      barcode: '8901030123457',
      quantity: 0,
      sellingPrice: 60.00,
      status: StockStatus.outOfStock,
    ),
    StockItem(
      id: 's4',
      name: 'Wool Winter Coat',
      category: 'Clothing',
      sku: 'CL-022',
      barcode: '8901030111135',
      quantity: 27,
      sellingPrice: 3200.00,
      status: StockStatus.slowMoving,
    ),
    StockItem(
      id: 's5',
      name: 'Wheat Bread',
      category: 'Grocery',
      sku: 'BR-5001',
      barcode: '8901030123458',
      quantity: 34,
      sellingPrice: 40.00,
      status: StockStatus.inStock,
    ),
    StockItem(
      id: 's6',
      name: 'Apple Soda',
      category: 'Beverages',
      sku: 'SD-0091',
      barcode: '8901030123460',
      quantity: 6,
      sellingPrice: 30.00,
      status: StockStatus.lowStock,
      lowStockThreshold: 10,
    ),
  ];
}