import '../../../../core/utils/error_mapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/product_repository.dart';
import '../states/product_state.dart';

final productControllerProvider = NotifierProvider.autoDispose<ProductController, ProductState>(
  ProductController.new,
);

class ProductController extends Notifier<ProductState> {
  late final TextEditingController nameController;

  ProductRepository get _repository => ref.read(productRepositoryProvider);

  @override
  ProductState build() {
    Future.microtask(getProduct);

    nameController = TextEditingController();
    ref.onDispose(() => nameController.dispose());
    return const ProductState();
  }

  void selectCategory(String category) {
    state = state.copyWith(selectedCategory: category);
  }

  void updateSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }



  // ───────────────────────────────────────────────
  // GET
  // ───────────────────────────────────────────────
  Future<bool> getProduct() async {
    state = state.copyWith(isProductLoading: true);
    try {
      final product = await _repository.getProduct();
      state = state.copyWith(
        isProductLoading: false,
        productModel: product,
      );
      return true;
    } catch (error) {
      state = state.copyWith(
        isProductLoading: false,
        errorMessage: getErrorMessage(error),
      );
      return false;
    }
  }

}
