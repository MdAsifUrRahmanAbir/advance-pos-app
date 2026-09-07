import 'package:flutter_riverpod/flutter_riverpod.dart';

class ForgotPasswordController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() {
    return const AsyncValue.data(null);
  }
}

final forgotPasswordControllerProvider = NotifierProvider<ForgotPasswordController, AsyncValue<void>>(ForgotPasswordController.new);
