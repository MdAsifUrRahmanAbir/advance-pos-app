import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/sales_replacement_add_repository.dart';
import '../states/sales_replacement_add_state.dart';

final salesReplacementAddControllerProvider = NotifierProvider.autoDispose<SalesReplacementAddController, SalesReplacementAddState>(
  SalesReplacementAddController.new,
);

class SalesReplacementAddController extends Notifier<SalesReplacementAddState> {
  late final TextEditingController nameController;

  SalesReplacementAddRepository get _repository => ref.read(salesReplacementAddRepositoryProvider);

  @override
  SalesReplacementAddState build() {
    nameController = TextEditingController();
    ref.onDispose(() => nameController.dispose());
    return const SalesReplacementAddState();
  }
}
