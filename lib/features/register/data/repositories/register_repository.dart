import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:template_test/core/network/api_client.dart';

final registerRepositoryProvider = Provider<RegisterRepository>((ref) {
  return RegisterRepository(ref.watch(apiClientProvider));
});

class RegisterRepository {
  final ApiClient _apiClient;
  RegisterRepository(this._apiClient);
}
