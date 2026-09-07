import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() {
    return const AsyncValue.data(null);
  }
}

final profileControllerProvider = NotifierProvider<ProfileController, AsyncValue<void>>(ProfileController.new);
