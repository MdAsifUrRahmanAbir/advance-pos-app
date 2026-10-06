import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/error_mapper.dart';
import '../../data/repositories/home_repository.dart';
import '../states/home_state.dart';

final homeControllerProvider =
NotifierProvider.autoDispose<HomeController, HomeState>(HomeController.new);

class HomeController extends Notifier<HomeState> {
  @override
  HomeState build() {
    Future.microtask(getDashboard);
    return HomeState.initial().copyWith(isDashboardLoading: true);
  }

  HomeRepository get _repository => ref.read(homeRepositoryProvider);

  /// Switches the Overview slice (today / monthly) of the fetched dashboard.
  void selectPeriod(String period) {
    state = state.copyWith(selectedPeriod: period);
  }

  /// Switches the chart range (7days / 12months).
  void selectChartRange(String range) {
    state = state.copyWith(selectedChartRange: range);
  }

  // ───────────────────────────────────────────────
  // GET
  // ───────────────────────────────────────────────
  Future<bool> getDashboard() async {
    state = state.copyWith(isDashboardLoading: true);
    try {
      final dashboard = await _repository.getDashboard();
      if (!ref.mounted) return false;
      state = state.copyWith(
        isDashboardLoading: false,
        dashboardModel: dashboard,
      );
      return true;
    } catch (error, stackTrace) {
      if (!ref.mounted) return false;
      state = state.copyWith(
        isDashboardLoading: false,
        errorMessage: getErrorMessage(error, stackTrace),
      );
      return false;
    }
  }
}