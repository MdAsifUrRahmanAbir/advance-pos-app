import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/error_mapper.dart';
import '../../data/repositories/expense_repository.dart';
import '../states/expense_detail_state.dart';

final expenseDetailControllerProvider = NotifierProvider.autoDispose
    .family<ExpenseDetailController, ExpenseDetailState, String>(
  ExpenseDetailController.new,
);

class ExpenseDetailController extends Notifier<ExpenseDetailState> {
  ExpenseDetailController(this.expenseNo);

  final String expenseNo;

  ExpenseRepository get _repository => ref.read(expenseRepositoryProvider);

  @override
  ExpenseDetailState build() {
    Future.microtask(getExpenseDetail);
    return const ExpenseDetailState(isInitialLoading: true);
  }

  // ───────────────────────────────────────────────
  // GET
  // ───────────────────────────────────────────────
  Future<bool> getExpenseDetail() async {
    state = state.copyWith(isInitialLoading: state.detail == null);
    try {
      final detail = await _repository.getExpenseDetail(expenseNo);
      if (!ref.mounted) return true;
      state = state.copyWith(isInitialLoading: false, detail: detail);
      return true;
    } catch (error, stackTrace) {
      if (!ref.mounted) return false;
      state = state.copyWith(
        isInitialLoading: false,
        errorMessage: getErrorMessage(error, stackTrace),
      );
      return false;
    }
  }
}