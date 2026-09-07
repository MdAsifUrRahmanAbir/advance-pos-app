import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() {
    return const AsyncValue.data(null);
  }
}

final homeControllerProvider = NotifierProvider<HomeController, AsyncValue<void>>(HomeController.new);
