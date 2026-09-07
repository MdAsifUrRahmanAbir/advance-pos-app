import 'package:flutter_riverpod/flutter_riverpod.dart';

class SearchController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() {
    return const AsyncValue.data(null);
  }
}

final searchControllerProvider = NotifierProvider<SearchController, AsyncValue<void>>(SearchController.new);
