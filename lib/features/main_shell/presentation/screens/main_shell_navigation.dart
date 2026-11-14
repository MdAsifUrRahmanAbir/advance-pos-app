import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../routes/route_names.dart';
import '../controllers/main_shell_controller.dart';

extension MainShellNavigation on BuildContext {
  /// "Go to Dashboard": back to the main shell with the Home tab selected.
  /// The shell usually stays mounted under the screen we leave, so its
  /// selected tab has to be reset explicitly.
  void goToDashboard() {
    ProviderScope.containerOf(this, listen: false)
        .read(mainShellControllerProvider.notifier)
        .showHome();
    go(RouteNames.mainShell);
  }
}