import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/sales_replacement_edit_repository.dart';
import '../states/sales_replacement_edit_state.dart';

final salesReplacementEditControllerProvider = NotifierProvider.autoDispose<SalesReplacementEditController, SalesReplacementEditState>(
  SalesReplacementEditController.new,
);

class SalesReplacementEditController extends Notifier<SalesReplacementEditState> {
  late final TextEditingController nameController;

  SalesReplacementEditRepository get _repository => ref.read(salesReplacementEditRepositoryProvider);

  @override
  SalesReplacementEditState build() {
    nameController = TextEditingController();
    ref.onDispose(() => nameController.dispose());
    return const SalesReplacementEditState();
  }
}
