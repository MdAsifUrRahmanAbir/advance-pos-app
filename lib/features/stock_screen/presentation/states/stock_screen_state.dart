class StockScreenState {
  final bool isInitialLoading;
  final String? errorMessage;

  const StockScreenState({
    this.isInitialLoading = false,
    this.errorMessage,
  });

  StockScreenState copyWith({
    bool? isInitialLoading,
    String? errorMessage,
  }) {
    return StockScreenState(
      isInitialLoading: isInitialLoading ?? this.isInitialLoading,
      errorMessage: errorMessage,
    );
  }
}
