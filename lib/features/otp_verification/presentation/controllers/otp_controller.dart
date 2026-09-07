import 'package:flutter_riverpod/flutter_riverpod.dart';

class OtpController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() {
    return const AsyncValue.data(null);
  }
}

final otpControllerProvider = NotifierProvider<OtpController, AsyncValue<void>>(OtpController.new);
