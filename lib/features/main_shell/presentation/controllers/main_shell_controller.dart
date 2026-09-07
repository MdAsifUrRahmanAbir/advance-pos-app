import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Tracks which bottom-nav tab is active. Purely UI state — no
/// network/data-layer involvement, so it's safe to live in
/// presentation/controllers per the architecture rules.
class MainShellController extends Notifier<int> {
  @override
  int build() => 0;

  void selectTab(int index) => state = index;
}

final mainShellControllerProvider = NotifierProvider<MainShellController, int>(MainShellController.new);