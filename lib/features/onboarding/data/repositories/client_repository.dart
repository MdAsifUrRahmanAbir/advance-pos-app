import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/session/api_params.dart';
import '../models/client_info_model.dart';

final clientRepositoryProvider = Provider<ClientRepository>((ref) {
  return ClientRepository(ref.watch(apiClientProvider));
});

/// Company (client) verification. Cache policy: never — the answer decides
/// which server the app talks to, so it is always fetched fresh.
class ClientRepository {
  final ApiClient _apiClient;
  ClientRepository(this._apiClient);

  // AUTO-GENERATED API METHOD
  Future<ClientInfoModel> getClientInfo(String compCode) async {
    final response = await _apiClient.get(
      ApiEndpoints.clientInfo,
      queryParameters: {
        'comp_code': compCode,
        'app': ApiParamDefaults.clientApp,
        'system_token': "2nMDQU2TodIJH9Y8oycSUKNDVcHh5KZKCbLAmamU",
      },
    );
    return ClientInfoModel.fromJson(response.data);
  }
}