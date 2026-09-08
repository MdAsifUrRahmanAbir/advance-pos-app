import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../states/new_sale_state.dart';

final newSaleControllerProvider =
NotifierProvider.autoDispose<NewSaleController, NewSaleState>(NewSaleController.new);

class NewSaleController extends Notifier<NewSaleState> {
  late final TextEditingController searchController;

  @override
  NewSaleState build() {
    searchController = TextEditingController();
    ref.onDispose(() => searchController.dispose());

    // TODO: wire to productRepositoryProvider.getProducts() once the
    // new_sale/data/repositories layer is ready. Currently mock data.
    return NewSaleState.initial().copyWith(allProducts: _mockProducts);
  }

  void updateSearchQuery(String query) {
    searchController.value = searchController.value.copyWith(
      text: query,
      selection: TextSelection.collapsed(offset: query.length),
    );
    state = state.copyWith(searchQuery: query);
  }

  void selectCategory(String categoryKey) {
    state = state.copyWith(selectedCategory: categoryKey);
  }

  /// Adds [product] to the cart, or increments its quantity by one if
  /// it's already there — so scanning/tapping the same item twice grows
  /// one line rather than creating a duplicate.
  void addToCart(ProductItem product) {
    // TODO: wire to cartControllerProvider.addItem(product) once the
    // shared cart controller exists.
    final items = List<CartLineItem>.from(state.cartItems);
    final existingIndex = items.indexWhere((line) => line.product.id == product.id);

    if (existingIndex == -1) {
      items.add(CartLineItem(product: product, quantity: 1));
    } else {
      items[existingIndex] = items[existingIndex].copyWith(quantity: items[existingIndex].quantity + 1);
    }

    state = state.copyWith(cartItems: items);
  }

  void increaseQty(String productId) {
    state = state.copyWith(
      cartItems: [
        for (final line in state.cartItems)
          if (line.product.id == productId) line.copyWith(quantity: line.quantity + 1) else line,
      ],
    );
  }

  /// Decrements quantity, removing the line entirely once it hits zero.
  void decreaseQty(String productId) {
    final items = <CartLineItem>[];
    for (final line in state.cartItems) {
      if (line.product.id != productId) {
        items.add(line);
        continue;
      }
      if (line.quantity > 1) items.add(line.copyWith(quantity: line.quantity - 1));
      // quantity == 1 -> dropped, i.e. removed from cart
    }
    state = state.copyWith(cartItems: items);
  }

  void removeFromCart(String productId) {
    state = state.copyWith(
      cartItems: state.cartItems.where((line) => line.product.id != productId).toList(),
    );
  }

  /// Resolves a scanned barcode against [NewSaleState.allProducts] —
  /// no separate repository call needed just to resolve a scanned code.
  /// Fills [searchController]/`searchQuery` with the raw code either
  /// way, adds the product to the cart on a match, and sets
  /// [NewSaleState.errorMessage] to exactly "Product not found." on a
  /// miss so the view can surface that message without duplicating the
  /// lookup itself.
  ProductItem? handleScannedCode(String code) {
    final match = state.allProducts
        .where((p) => p.barcode == code || p.sku == code)
        .firstOrNull;

    updateSearchQuery(code);

    if (match != null) {
      addToCart(match);
      state = state.copyWith(errorMessage: null);
    } else {
      state = state.copyWith(errorMessage: 'Product not found.');
    }

    return match;
  }

  static const _mockProducts = [
    ProductItem(id: 'p1', name: 'Fresh Milk 1L', sku: 'MK-1002', price: 60.00, categoryKey: 'grocery', barcode: '8901030123457'),
    ProductItem(id: 'p2', name: 'Wheat Bread', sku: 'BR-5001', price: 40.00, categoryKey: 'grocery', barcode: '8901030123458'),
    ProductItem(id: 'p3', name: 'Organic Eggs', sku: 'EG-1200', price: 120.00, categoryKey: 'grocery', barcode: '8901030123459'),
    ProductItem(id: 'p4', name: 'Apple Soda', sku: 'SD-0091', price: 30.00, categoryKey: 'beverages', barcode: '8901030123460'),
  ];
}