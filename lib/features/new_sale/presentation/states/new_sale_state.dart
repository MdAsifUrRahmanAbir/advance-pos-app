import 'package:flutter/foundation.dart';
import '../../data/models/get_discount.dart';
import '../../data/models/stocks_model.dart';


// 1. Add a `stock` field to ProductItem (required — every construction site
//    below is updated to pass it):
class ProductItem {
  final String id;
  final String name;
  final String sku;
  final double price;
  final String categoryKey;
  final int stock;           // <-- NEW: available pcs from Stock endpoint
  final String? imageUrl;
  final String? barcode;

  const ProductItem({
    required this.id,
    required this.name,
    required this.sku,
    required this.price,
    required this.categoryKey,
    required this.stock,     // <-- NEW
    this.imageUrl,
    this.barcode,
  });
}

// 2. New result type for the scan flow, so the view can distinguish
//    "added" / "out of stock" / "not found" without overloading a bool:
enum ScanOutcome { added, outOfStock, notFound }

class ScanResult {
  final ProductItem? product;
  final ScanOutcome outcome;
  const ScanResult({required this.product, required this.outcome});
}


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
  final bool isProductsLoading;
  final bool isLoadingMore;
  final String? errorMessage;
  final String? technicalDetails;
  final String searchQuery;
  final int? selectedCategoryId;
  final StocksModel? productModel;
  final List<ProductItem> allItems;
  final int currentStart;
  final bool hasMore;
  final List<CartLineItem> cartItems;
  final GetDiscountModel? getDiscountModel;
  final bool isGetDiscountLoading;

  const NewSaleState({
    this.isProductsLoading = false,
    this.isLoadingMore = false,
    this.errorMessage,
    this.technicalDetails,
    this.searchQuery = '',
    this.selectedCategoryId,
    this.productModel,
    this.allItems = const [],
    this.currentStart = 0,
    this.hasMore = true,
    this.cartItems = const [],
    this.getDiscountModel,
    this.isGetDiscountLoading = false,
  });

  factory NewSaleState.initial() => const NewSaleState();

  List<ProductItem> get filteredProducts => allItems;

  int get cartItemCount => cartItems.fold(0, (sum, line) => sum + line.quantity);

  double get cartTotal => cartItems.fold(0.0, (sum, line) => sum + line.lineTotal);

  NewSaleState copyWith({
    bool? isProductsLoading,
    bool? isLoadingMore,
    String? errorMessage,
    String? technicalDetails,
    String? searchQuery,
    int? selectedCategoryId,
    bool clearSelectedCategoryId = false,
    StocksModel? productModel,
    List<ProductItem>? allItems,
    int? currentStart,
    bool? hasMore,
    List<CartLineItem>? cartItems,
    GetDiscountModel? getDiscountModel,
    bool? isGetDiscountLoading,
  }) {
    return NewSaleState(
      isProductsLoading: isProductsLoading ?? this.isProductsLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage: errorMessage,
      technicalDetails: technicalDetails,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategoryId: clearSelectedCategoryId ? null : (selectedCategoryId ?? this.selectedCategoryId),
      productModel: productModel ?? this.productModel,
      allItems: allItems ?? this.allItems,
      currentStart: currentStart ?? this.currentStart,
      hasMore: hasMore ?? this.hasMore,
      cartItems: cartItems ?? this.cartItems,
      getDiscountModel: getDiscountModel ?? this.getDiscountModel,
      isGetDiscountLoading: isGetDiscountLoading ?? this.isGetDiscountLoading,
    );
  }
}