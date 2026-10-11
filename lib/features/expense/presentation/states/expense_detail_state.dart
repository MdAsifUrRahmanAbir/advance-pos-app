import '../../data/model/expense_detail_model.dart' show ExpenseDetailModel;

class ExpenseDetailState {
  final bool isInitialLoading;
  final String? errorMessage;
  final ExpenseDetailModel? detail;

  const ExpenseDetailState({
    this.isInitialLoading = false,
    this.errorMessage,
    this.detail,
  });

  ExpenseDetailState copyWith({
    bool? isInitialLoading,
    String? errorMessage,
    ExpenseDetailModel? detail,
  }) {
    return ExpenseDetailState(
      isInitialLoading: isInitialLoading ?? this.isInitialLoading,
      errorMessage: errorMessage,
      detail: detail ?? this.detail,
    );
  }
}