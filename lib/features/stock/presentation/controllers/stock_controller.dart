import '../../../../core/utils/error_mapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/stock_repository.dart';
import '../states/stock_state.dart';

final stockControllerProvider = NotifierProvider.autoDispose<StockController, StockState>(
  StockController.new,
);

class StockController extends Notifier<StockState> {
  late final TextEditingController nameController;

  StockRepository get _repository => ref.read(stockRepositoryProvider);

  @override
  StockState build() {
    Future.microtask(getProduct);

    nameController = TextEditingController();
    ref.onDispose(() => nameController.dispose());
    return const StockState();
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
    state = state.copyWith(isStockLoading: true);
    try {
      final product = await _repository.getProduct();
      state = state.copyWith(
        isStockLoading: false,
        stockModel: product,
      );
      return true;
    } catch (error) {
      state = state.copyWith(
        isStockLoading: false,
        errorMessage: getErrorMessage(error),
      );
      return false;
    }
  }

}
