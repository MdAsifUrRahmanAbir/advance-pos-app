import 'package:flutter_riverpod/flutter_riverpod.dart';

class TermsPrivacyController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() {
    return const AsyncValue.data(null);
  }
}

final termsPrivacyControllerProvider = NotifierProvider<TermsPrivacyController, AsyncValue<void>>(TermsPrivacyController.new);
