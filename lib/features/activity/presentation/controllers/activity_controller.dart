import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../states/activity_state.dart';


class ActivityController extends Notifier<ActivityState> {
  @override
  ActivityState build() => const ActivityState();

  void selectFilter(String filter) {
    state = state.copyWith(selectedFilter: filter);
  }

}

final activityControllerProvider =
NotifierProvider.autoDispose<ActivityController, ActivityState>(ActivityController.new);