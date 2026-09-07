import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../states/notifications_state.dart';

class NotificationController extends Notifier<NotificationsState> {
  @override
  NotificationsState build() => const NotificationsState();

  void selectFilter(String filter) {
    state = state.copyWith(selectedFilter: filter);
  }

  // TODO: call repository markAllAsRead(), then refresh the fetched list.
  Future<bool> markAllAsRead() async {
    // Placeholder until the API is wired up.
    return true;
  }
}

final notificationControllerProvider =
NotifierProvider.autoDispose<NotificationController, NotificationsState>(NotificationController.new);