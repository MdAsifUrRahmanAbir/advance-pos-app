import 'package:flutter_riverpod/flutter_riverpod.dart';

class SystemController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() {
    return const AsyncValue.data(null);
  }
}

final systemControllerProvider = NotifierProvider<SystemController, AsyncValue<void>>(SystemController.new);
