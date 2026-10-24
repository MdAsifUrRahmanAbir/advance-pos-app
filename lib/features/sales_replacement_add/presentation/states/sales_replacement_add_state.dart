class SalesReplacementAddState {
  final bool isInitialLoading;
  final String? errorMessage;

  const SalesReplacementAddState({
    this.isInitialLoading = false,
    this.errorMessage,
  });

  SalesReplacementAddState copyWith({
    bool? isInitialLoading,
    String? errorMessage,
  }) {
    return SalesReplacementAddState(
      isInitialLoading: isInitialLoading ?? this.isInitialLoading,
      errorMessage: errorMessage,
    );
  }
}
