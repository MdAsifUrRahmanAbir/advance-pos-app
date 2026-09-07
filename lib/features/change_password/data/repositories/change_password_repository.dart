import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:template_test/core/network/api_client.dart';

final changePasswordRepositoryProvider = Provider<ChangePasswordRepository>((ref) {
  return ChangePasswordRepository(ref.watch(apiClientProvider));
});

class ChangePasswordRepository {
  final ApiClient _apiClient;
  ChangePasswordRepository(this._apiClient);
}
