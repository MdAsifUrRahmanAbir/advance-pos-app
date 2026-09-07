import 'package:flutter_riverpod/flutter_riverpod.dart';

class HelpSupportController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() {
    return const AsyncValue.data(null);
  }
}

final helpSupportControllerProvider = NotifierProvider<HelpSupportController, AsyncValue<void>>(HelpSupportController.new);
