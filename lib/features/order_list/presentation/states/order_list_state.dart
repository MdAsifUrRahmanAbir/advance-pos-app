class OrderListState {
  final String selectedFilter;
  final bool isOrdersLoading;
  final String? errorMessage;

  const OrderListState({
    this.selectedFilter = 'all',
    this.isOrdersLoading = false,
    this.errorMessage,
  });

  OrderListState copyWith({
    String? selectedFilter,
    bool? isOrdersLoading,
    String? errorMessage,
  }) {
    return OrderListState(
      selectedFilter: selectedFilter ?? this.selectedFilter,
      isOrdersLoading: isOrdersLoading ?? this.isOrdersLoading,
      errorMessage: errorMessage,
    );
  }
}