class ActivityState {
  final String selectedFilter;
  final bool isActivitiesLoading;
  final String? errorMessage;

  const ActivityState({
    this.selectedFilter = 'today',
    this.isActivitiesLoading = false,
    this.errorMessage,
  });

  ActivityState copyWith({
    String? selectedFilter,
    bool? isActivitiesLoading,
    String? errorMessage,
  }) {
    return ActivityState(
      selectedFilter: selectedFilter ?? this.selectedFilter,
      isActivitiesLoading: isActivitiesLoading ?? this.isActivitiesLoading,
      errorMessage: errorMessage,
    );
  }
}