import '../../data/models/sales_replacement_model.dart' show ResultDatum;

enum SalesReplacementDatePreset {
  all,
  today,
  yesterday,
  last7Days,
  thisMonth,
  lastMonth,
  custom,
}

/// Multi-flag state: list loading, paging and deleting are independent.
class SalesReplacementState {
  final bool isInitialLoading;
  final bool isLoadingMore;
  final bool isLoadMoreFailed;
  final String? errorMessage;

  /// Dev-facing breakdown for the full "Technical Details" screen.
  final String? technicalDetails;
  final List<ResultDatum> items;
  final int totalCount;
  final bool hasMore;
  final String searchQuery;
  final SalesReplacementDatePreset datePreset;
  final DateTime? fromDate;
  final DateTime? toDate;

  /// returnBillNo currently being deleted; null when no delete is running.
  final String? deletingBillNo;

  const SalesReplacementState({
    this.isInitialLoading = false,
    this.isLoadingMore = false,
    this.isLoadMoreFailed = false,
    this.errorMessage,
    this.technicalDetails,
    this.items = const [],
    this.totalCount = 0,
    this.hasMore = false,
    this.searchQuery = '',
    this.datePreset = SalesReplacementDatePreset.all,
    this.fromDate,
    this.toDate,
    this.deletingBillNo,
  });

  bool get isDeleting => deletingBillNo != null;

  SalesReplacementState copyWith({
    bool? isInitialLoading,
    bool? isLoadingMore,
    bool? isLoadMoreFailed,
    String? errorMessage,
    String? technicalDetails,
    List<ResultDatum>? items,
    int? totalCount,
    bool? hasMore,
    String? searchQuery,
    SalesReplacementDatePreset? datePreset,
    DateTime? fromDate,
    DateTime? toDate,
    bool clearDates = false,
    String? deletingBillNo,
    bool clearDeleting = false,
  }) {
    return SalesReplacementState(
      isInitialLoading: isInitialLoading ?? this.isInitialLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isLoadMoreFailed: isLoadMoreFailed ?? this.isLoadMoreFailed,
      errorMessage: errorMessage,
      technicalDetails: technicalDetails,
      items: items ?? this.items,
      totalCount: totalCount ?? this.totalCount,
      hasMore: hasMore ?? this.hasMore,
      searchQuery: searchQuery ?? this.searchQuery,
      datePreset: datePreset ?? this.datePreset,
      fromDate: clearDates ? null : (fromDate ?? this.fromDate),
      toDate: clearDates ? null : (toDate ?? this.toDate),
      deletingBillNo: clearDeleting
          ? null
          : (deletingBillNo ?? this.deletingBillNo),
    );
  }
}