import 'package:flutter/foundation.dart';

/// Presentation-layer shape until the real product API is wired via
/// add_api_feature.py — at that point this maps from the real ProductModel
/// (`barcode` mirrors `ResultDatum.barcode`/`systemBarcode`).
@immutable
class ProductItem {
  final String id;
  final String name;
  final String sku;
  final double price;
  final String categoryKey; // 'beverages' | 'snacks' | 'grocery'
  final String? barcode;
  final String? imageUrl;

  const ProductItem({
    required this.id,
    required this.name,
    required this.sku,
    required this.price,
    required this.categoryKey,
    this.barcode,
    this.imageUrl,
  });
}

/// One line in the cart — a [product] plus how many of it were added.
/// Kept separate from [ProductItem] itself so the product catalog stays
/// immutable/shared while cart quantity is per-sale, mutable state.
@immutable
class CartLineItem {
  final ProductItem product;
  final int quantity;

  const CartLineItem({required this.product, required this.quantity});

  double get lineTotal => product.price * quantity;

  CartLineItem copyWith({int? quantity}) {
    return CartLineItem(product: product, quantity: quantity ?? this.quantity);
  }
}

@immutable
class NewSaleState {
  final bool isLoading;
  final String? errorMessage;
  final String searchQuery;
  final String selectedCategory; // 'all' | 'beverages' | 'snacks' | 'grocery'
  final List<ProductItem> allProducts;
  final List<CartLineItem> cartItems;

  const NewSaleState({
    this.isLoading = false,
    this.errorMessage,
    this.searchQuery = '',
    this.selectedCategory = 'all',
    this.allProducts = const [],
    this.cartItems = const [],
  });

  factory NewSaleState.initial() => const NewSaleState();

  List<ProductItem> get filteredProducts {
    return allProducts.where((p) {
      final matchesCategory =
          selectedCategory == 'all' || p.categoryKey == selectedCategory;
      final matchesQuery =
          searchQuery.isEmpty ||
          p.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
          p.sku.toLowerCase().contains(searchQuery.toLowerCase());
      return matchesCategory && matchesQuery;
    }).toList();
  }

  /// Derived from [cartItems] so quantity/line data and the badge/total
  /// shown on [CartSummaryBar] can never drift apart.
  int get cartItemCount =>
      cartItems.fold(0, (sum, line) => sum + line.quantity);

  double get cartTotal =>
      cartItems.fold(0.0, (sum, line) => sum + line.lineTotal);

  NewSaleState copyWith({
    bool? isLoading,
    String? errorMessage,
    String? searchQuery,
    String? selectedCategory,
    List<ProductItem>? allProducts,
    List<CartLineItem>? cartItems,
  }) {
    return NewSaleState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      allProducts: allProducts ?? this.allProducts,
      cartItems: cartItems ?? this.cartItems,
    );
  }
}
