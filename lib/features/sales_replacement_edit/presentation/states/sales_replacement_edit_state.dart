class SalesReplacementEditState {
  final bool isInitialLoading;
  final String? errorMessage;

  const SalesReplacementEditState({
    this.isInitialLoading = false,
    this.errorMessage,
  });

  SalesReplacementEditState copyWith({
    bool? isInitialLoading,
    String? errorMessage,
  }) {
    return SalesReplacementEditState(
      isInitialLoading: isInitialLoading ?? this.isInitialLoading,
      errorMessage: errorMessage,
    );
  }
}
