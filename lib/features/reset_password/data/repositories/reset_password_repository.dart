import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:template_test/core/network/api_client.dart';

final resetPasswordRepositoryProvider = Provider<ResetPasswordRepository>((ref) {
  return ResetPasswordRepository(ref.watch(apiClientProvider));
});

class ResetPasswordRepository {
  final ApiClient _apiClient;
  ResetPasswordRepository(this._apiClient);
}
