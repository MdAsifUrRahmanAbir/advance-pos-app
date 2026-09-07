import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:advance_pos_app/core/network/api_client.dart';

final forgotPasswordRepositoryProvider = Provider<ForgotPasswordRepository>((ref) {
  return ForgotPasswordRepository(ref.watch(apiClientProvider));
});

class ForgotPasswordRepository {
  final ApiClient _apiClient;
  ForgotPasswordRepository(this._apiClient);
}
