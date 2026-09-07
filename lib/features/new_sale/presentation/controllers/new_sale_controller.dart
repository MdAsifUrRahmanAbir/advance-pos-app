import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../states/new_sale_state.dart';

final newSaleControllerProvider =
NotifierProvider.autoDispose<NewSaleController, NewSaleState>(NewSaleController.new);

class NewSaleController extends Notifier<NewSaleState> {
  @override
  NewSaleState build() {
    // TODO: wire to productRepositoryProvider.getProducts() once the
    // new_sale/data/repositories layer is ready. Currently mock data.
    return NewSaleState.initial().copyWith(
      allProducts: _mockProducts,
      cartItemCount: 3,
      cartTotal: 1250.00,
    );
  }

  void updateSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void selectCategory(String categoryKey) {
    state = state.copyWith(selectedCategory: categoryKey);
  }

  void addToCart(ProductItem product) {
    // TODO: wire to cartControllerProvider.addItem(product) once the
    // shared cart controller exists. For now, increments local mock totals.
    state = state.copyWith(
      cartItemCount: state.cartItemCount + 1,
      cartTotal: state.cartTotal + product.price,
    );
  }

  static const _mockProducts = [
    ProductItem(id: 'p1', name: 'Fresh Milk 1L', sku: 'MK-1002', price: 60.00, categoryKey: 'grocery'),
    ProductItem(id: 'p2', name: 'Wheat Bread', sku: 'BR-5001', price: 40.00, categoryKey: 'grocery'),
    ProductItem(id: 'p3', name: 'Organic Eggs', sku: 'EG-1200', price: 120.00, categoryKey: 'grocery'),
    ProductItem(id: 'p4', name: 'Apple Soda', sku: 'SD-0091', price: 30.00, categoryKey: 'beverages'),
  ];
}