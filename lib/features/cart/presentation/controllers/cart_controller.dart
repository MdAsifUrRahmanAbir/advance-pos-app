import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../states/cart_state.dart';

final cartControllerProvider =
    NotifierProvider.autoDispose<CartController, CartState>(CartController.new);

class CartController extends Notifier<CartState> {
  @override
  CartState build() {
    // TODO: wire to cartRepositoryProvider.getCurrentCart() once the
    // cart/data/repositories layer is ready. Currently mock data matching
    // the New Sale flow's cart contents.
    return CartState.initial().copyWith(
      items: const [
        CartLineItem(
          id: 'p1',
          name: 'Quantum Wireless Mouse',
          unitPrice: 450.00,
          quantity: 2,
        ),
        CartLineItem(
          id: 'p2',
          name: 'Minimalist Leather Backpack',
          unitPrice: 300.00,
          quantity: 1,
        ),
        CartLineItem(
          id: 'p3',
          name: 'Smart LED Lamp',
          unitPrice: 50.00,
          quantity: 1,
        ),
      ],
      customerName: 'Walk-In Customer',
      discountPercent: 5,
      taxPercent: 13,
      rounding: -0.12,
    );
  }

  void incrementQuantity(String itemId) {
    state = state.copyWith(
      items: [
        for (final item in state.items)
          if (item.id == itemId)
            item.copyWith(quantity: item.quantity + 1)
          else
            item,
      ],
    );
  }

  void decrementQuantity(String itemId) {
    state = state.copyWith(
      items: [
        for (final item in state.items)
          if (item.id == itemId && item.quantity > 1)
            item.copyWith(quantity: item.quantity - 1)
          else
            item,
      ],
    );
  }

  void removeItem(String itemId) {
    state = state.copyWith(
      items: state.items.where((item) => item.id != itemId).toList(),
    );
  }

  void clearAll() {
    state = state.copyWith(items: []);
  }

  void updateCustomer(String name) {
    state = state.copyWith(customerName: name);
  }

  void updateRemarks(String remarks) {
    state = state.copyWith(remarks: remarks);
  }

  void updateReferenceNo(String referenceNo) {
    state = state.copyWith(referenceNo: referenceNo);
  }
}
