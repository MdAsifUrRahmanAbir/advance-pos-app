import '../../data/models/dashboard_model.dart';

/// Display-only shapes derived from [DashboardModel] (see
/// dashboard_view_mapper.dart). These are NOT data/models.

class OverviewData {
  final double amount;
  final int orders;
  final int items;
  final double? discount; // today only
  final double? vat; // today only

  const OverviewData({
    required this.amount,
    required this.orders,
    required this.items,
    this.discount,
    this.vat,
  });
}

class SalesTrendData {
  final List<String> labels;
  final List<double> values;
  final double maxAmount;
  final double totalAmount;
  final int orderCount;
  final int itemCount;
  final bool isMonthlyRange;
  final String peakLabel;

  const SalesTrendData({
    required this.labels,
    required this.values,
    required this.maxAmount,
    required this.totalAmount,
    required this.orderCount,
    required this.itemCount,
    required this.isMonthlyRange,
    required this.peakLabel,
  });

  bool get hasData => maxAmount > 0 && values.isNotEmpty;
}

class HomeState {
  /// Overview scope.
  static const List<String> periods = ['today', 'monthly'];

  /// Chart scope.
  static const List<String> chartRanges = ['7days', '12months'];

  final String? errorMessage;
  final bool isOnline;
  final String selectedPeriod; // 'today' | 'monthly'
  final String selectedChartRange; // '7days' | '12months'
  final DashboardModel? dashboardModel;
  final bool isDashboardLoading;

  const HomeState({
    this.errorMessage,
    this.isOnline = true,
    this.selectedPeriod = 'today',
    this.selectedChartRange = '7days',
    this.dashboardModel,
    this.isDashboardLoading = false,
  });

  factory HomeState.initial() => const HomeState();

  HomeState copyWith({
    String? errorMessage,
    bool? isOnline,
    String? selectedPeriod,
    String? selectedChartRange,
    DashboardModel? dashboardModel,
    bool? isDashboardLoading,
  }) {
    return HomeState(
      errorMessage: errorMessage,
      isOnline: isOnline ?? this.isOnline,
      selectedPeriod: selectedPeriod ?? this.selectedPeriod,
      selectedChartRange: selectedChartRange ?? this.selectedChartRange,
      dashboardModel: dashboardModel ?? this.dashboardModel,
      isDashboardLoading: isDashboardLoading ?? this.isDashboardLoading,
    );
  }
}