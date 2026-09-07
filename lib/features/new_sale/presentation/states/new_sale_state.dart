import 'package:flutter/foundation.dart';

/// Presentation-layer shape until the real product API is wired via
/// add_api_feature.py — at that point this maps from the real ProductModel.
@immutable
class ProductItem {
  final String id;
  final String name;
  final String sku;
  final double price;
  final String categoryKey; // 'beverages' | 'snacks' | 'grocery'
  final String? imageUrl;

  const ProductItem({
    required this.id,
    required this.name,
    required this.sku,
    required this.price,
    required this.categoryKey,
    this.imageUrl,
  });
}

@immutable
class NewSaleState {
  final bool isLoading;
  final String? errorMessage;
  final String searchQuery;
  final String selectedCategory; // 'all' | 'beverages' | 'snacks' | 'grocery'
  final List<ProductItem> allProducts;
  final int cartItemCount;
  final double cartTotal;

  const NewSaleState({
    this.isLoading = false,
    this.errorMessage,
    this.searchQuery = '',
    this.selectedCategory = 'all',
    this.allProducts = const [],
    this.cartItemCount = 0,
    this.cartTotal = 0,
  });

  factory NewSaleState.initial() => const NewSaleState();

  List<ProductItem> get filteredProducts {
    return allProducts.where((p) {
      final matchesCategory =
          selectedCategory == 'all' || p.categoryKey == selectedCategory;
      final matchesQuery = searchQuery.isEmpty ||
          p.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
          p.sku.toLowerCase().contains(searchQuery.toLowerCase());
      return matchesCategory && matchesQuery;
    }).toList();
  }

  NewSaleState copyWith({
    bool? isLoading,
    String? errorMessage,
    String? searchQuery,
    String? selectedCategory,
    List<ProductItem>? allProducts,
    int? cartItemCount,
    double? cartTotal,
  }) {
    return NewSaleState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      allProducts: allProducts ?? this.allProducts,
      cartItemCount: cartItemCount ?? this.cartItemCount,
      cartTotal: cartTotal ?? this.cartTotal,
    );
  }
}