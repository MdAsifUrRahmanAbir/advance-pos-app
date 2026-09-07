import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:advance_pos_app/core/network/api_client.dart';

final registerRepositoryProvider = Provider<RegisterRepository>((ref) {
  return RegisterRepository(ref.watch(apiClientProvider));
});

class RegisterRepository {
  final ApiClient _apiClient;
  RegisterRepository(this._apiClient);
}
