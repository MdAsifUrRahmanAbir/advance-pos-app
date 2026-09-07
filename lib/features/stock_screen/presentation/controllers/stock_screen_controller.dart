import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/stock_screen_repository.dart';
import '../states/stock_screen_state.dart';

final stockScreenControllerProvider = NotifierProvider.autoDispose<StockScreenController, StockScreenState>(
  StockScreenController.new,
);

class StockScreenController extends Notifier<StockScreenState> {
  late final TextEditingController nameController;

  StockScreenRepository get _repository => ref.read(stockScreenRepositoryProvider);

  @override
  StockScreenState build() {
    nameController = TextEditingController();
    ref.onDispose(() => nameController.dispose());
    return const StockScreenState();
  }
}
