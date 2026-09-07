class AnalyticsState {
  final String selectedRange;
  final bool isAnalyticsLoading;
  final String? errorMessage;

  const AnalyticsState({
    this.selectedRange = 'W',
    this.isAnalyticsLoading = false,
    this.errorMessage,
  });

  AnalyticsState copyWith({
    String? selectedRange,
    bool? isAnalyticsLoading,
    String? errorMessage,
  }) {
    return AnalyticsState(
      selectedRange: selectedRange ?? this.selectedRange,
      isAnalyticsLoading: isAnalyticsLoading ?? this.isAnalyticsLoading,
      errorMessage: errorMessage,
    );
  }
}