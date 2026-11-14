import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/session/auth_session_controller.dart';

final mainShellControllerProvider = NotifierProvider<MainShellController, int>(
  MainShellController.new,
);

/// Selected bottom-nav / rail tab of the main shell.
class MainShellController extends Notifier<int> {
  static const int homeIndex = 0;

  /// Rebuilt on every login and logout, so a new session always opens on
  /// Home instead of the tab the previous session left selected.
  @override
  int build() {
    ref.watch(authSessionControllerProvider.select((s) => s.isLoggedIn));
    return homeIndex;
  }

  void selectTab(int index) => state = index;

  /// Selects the Home tab (used by "Go to Dashboard").
  void showHome() => state = homeIndex;
}