import 'package:flutter_riverpod/flutter_riverpod.dart';

class CartController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() {
    return const AsyncValue.data(null);
  }
}

final cartControllerProvider = NotifierProvider<CartController, AsyncValue<void>>(CartController.new);
