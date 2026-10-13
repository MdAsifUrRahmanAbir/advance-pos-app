import '../../data/model/expense_model.dart' show ResultDatum;

enum ExpenseDatePreset {
  all,
  today,
  yesterday,
  last7Days,
  thisMonth,
  lastMonth,
  custom,
}

class ExpenseState {
  final bool isInitialLoading;
  final bool isLoadingMore;
  final bool isLoadMoreFailed;
  final String? errorMessage;
  final List<ResultDatum> expenses;
  final int totalCount;
  final bool hasMore;
  final String searchQuery;
  final ExpenseDatePreset datePreset;
  final DateTime? fromDate;
  final DateTime? toDate;

  /// expenseNo currently being deleted; null when no delete is in flight.
  final String? deletingExpenseNo;

  const ExpenseState({
    this.isInitialLoading = false,
    this.isLoadingMore = false,
    this.isLoadMoreFailed = false,
    this.errorMessage,
    this.expenses = const [],
    this.totalCount = 0,
    this.hasMore = false,
    this.searchQuery = '',
    this.datePreset = ExpenseDatePreset.all,
    this.fromDate,
    this.toDate,
    this.deletingExpenseNo,
  });

  bool get isDeleting => deletingExpenseNo != null;

  ExpenseState copyWith({
    bool? isInitialLoading,
    bool? isLoadingMore,
    bool? isLoadMoreFailed,
    String? errorMessage,
    List<ResultDatum>? expenses,
    int? totalCount,
    bool? hasMore,
    String? searchQuery,
    ExpenseDatePreset? datePreset,
    DateTime? fromDate,
    DateTime? toDate,
    bool clearDates = false,
    String? deletingExpenseNo,
    bool clearDeleting = false,
  }) {
    return ExpenseState(
      isInitialLoading: isInitialLoading ?? this.isInitialLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isLoadMoreFailed: isLoadMoreFailed ?? this.isLoadMoreFailed,
      errorMessage: errorMessage,
      expenses: expenses ?? this.expenses,
      totalCount: totalCount ?? this.totalCount,
      hasMore: hasMore ?? this.hasMore,
      searchQuery: searchQuery ?? this.searchQuery,
      datePreset: datePreset ?? this.datePreset,
      fromDate: clearDates ? null : (fromDate ?? this.fromDate),
      toDate: clearDates ? null : (toDate ?? this.toDate),
      deletingExpenseNo: clearDeleting
          ? null
          : (deletingExpenseNo ?? this.deletingExpenseNo),
    );
  }
}