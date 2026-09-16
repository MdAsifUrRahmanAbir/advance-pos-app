import 'package:flutter_riverpod/flutter_riverpod.dart';

final mainShellControllerProvider = NotifierProvider<MainShellController, int>(
  MainShellController.new,
);

class MainShellController extends Notifier<int> {
  @override
  int build() => 0;

  void selectTab(int index) => state = index;
}