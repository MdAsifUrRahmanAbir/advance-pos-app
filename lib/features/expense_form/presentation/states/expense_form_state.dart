/// One committed expense line.
class ExpenseFormLine {
  final int headId;
  final String headName; // fallback label when master data has no match
  final int paymentSystemId;
  final int paymentAccId;
  final String localNarration;
  final num amount;

  const ExpenseFormLine({
    required this.headId,
    required this.headName,
    required this.paymentSystemId,
    required this.paymentAccId,
    required this.localNarration,
    required this.amount,
  });
}

/// Multi-flag state: loading the detail (edit) and submitting are
/// independent operations.
class ExpenseFormState {
  final bool isLoadingDetail;
  final bool isSubmitting;
  final String? loadError; // failed edit prefill
  final String? errorMessage; // last save failure
  final String? entryError; // entry-row validation

  /// Internal id of the expense being edited (from the loaded detail);
  /// null when adding or before the detail has loaded.
  final int? expenseId;
  final int branchId;
  final List<ExpenseFormLine> lines;
  final int? draftHeadId;

  /// null = "use the controller's default account" (see defaultPaymentAccId).
  final int? draftPaymentAccId;

  const ExpenseFormState({
    this.isLoadingDetail = false,
    this.isSubmitting = false,
    this.loadError,
    this.errorMessage,
    this.entryError,
    this.expenseId,
    required this.branchId,
    this.lines = const [],
    this.draftHeadId,
    this.draftPaymentAccId,
  });

  num get total => lines.fold<num>(0, (sum, l) => sum + l.amount);

  /// Placeholder rows for Skeletonizer while the edit prefill loads.
  static const List<ExpenseFormLine> skeletonLines = [
    ExpenseFormLine(
      headId: 0,
      headName: 'Head name placeholder',
      paymentSystemId: 0,
      paymentAccId: 0,
      localNarration: 'Narration placeholder',
      amount: 1000,
    ),
    ExpenseFormLine(
      headId: 0,
      headName: 'Head name placeholder',
      paymentSystemId: 0,
      paymentAccId: 0,
      localNarration: '',
      amount: 100,
    ),
  ];

  ExpenseFormState copyWith({
    bool? isLoadingDetail,
    bool? isSubmitting,
    String? loadError,
    bool clearLoadError = false,
    String? errorMessage,
    String? entryError,
    int? expenseId,
    int? branchId,
    List<ExpenseFormLine>? lines,
    int? draftHeadId,
    bool clearDraftHead = false,
    int? draftPaymentAccId,
  }) {
    return ExpenseFormState(
      isLoadingDetail: isLoadingDetail ?? this.isLoadingDetail,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      loadError: clearLoadError ? null : (loadError ?? this.loadError),
      errorMessage: errorMessage,
      entryError: entryError,
      expenseId: expenseId ?? this.expenseId,
      branchId: branchId ?? this.branchId,
      lines: lines ?? this.lines,
      draftHeadId: clearDraftHead ? null : (draftHeadId ?? this.draftHeadId),
      draftPaymentAccId: draftPaymentAccId ?? this.draftPaymentAccId,
    );
  }
}