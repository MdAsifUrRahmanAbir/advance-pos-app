import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../models/login_model.dart';

final loginRepositoryProvider = Provider<LoginRepository>((ref) {
  return LoginRepository(ref.watch(apiClientProvider));
});

class LoginRepository {
  final ApiClient _apiClient;
  LoginRepository(this._apiClient);

  /// POST /login — username/password sign-in.
  /// Cache policy: never (credentials, per-user response).
  Future<LoginModel> login({
    required String username,
    required String password,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.login,
      data: {'username': username, 'password': password},
    );
    return LoginModel.fromJson(response.data);
  }
}