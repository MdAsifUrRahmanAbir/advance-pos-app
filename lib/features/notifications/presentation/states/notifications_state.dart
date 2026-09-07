class NotificationsState {
  final String selectedFilter;
  final bool isNotificationsLoading;
  final String? errorMessage;

  const NotificationsState({
    this.selectedFilter = 'all',
    this.isNotificationsLoading = false,
    this.errorMessage,
  });

  NotificationsState copyWith({
    String? selectedFilter,
    bool? isNotificationsLoading,
    String? errorMessage,
  }) {
    return NotificationsState(
      selectedFilter: selectedFilter ?? this.selectedFilter,
      isNotificationsLoading: isNotificationsLoading ?? this.isNotificationsLoading,
      errorMessage: errorMessage,
    );
  }
}