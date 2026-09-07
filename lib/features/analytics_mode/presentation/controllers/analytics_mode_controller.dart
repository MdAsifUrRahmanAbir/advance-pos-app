import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../states/analytics_state.dart';


class AnalyticsController extends Notifier<AnalyticsState> {
  @override
  AnalyticsState build() => const AnalyticsState();

  void selectRange(String range) {
    state = state.copyWith(selectedRange: range);
  }

// TODO: once real analytics data is available, refetch/derive chart and
// category-breakdown values based on selectedRange here.
}

final analyticsControllerProvider =
NotifierProvider.autoDispose<AnalyticsController, AnalyticsState>(AnalyticsController.new);