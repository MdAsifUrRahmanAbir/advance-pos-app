import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:advance_pos_app/core/network/api_client.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../models/dashboard_model.dart';

final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  return HomeRepository(ref.watch(apiClientProvider));
});

class HomeRepository {
  final ApiClient _apiClient;
  HomeRepository(this._apiClient);

  // AUTO-GENERATED API METHOD
  Future<DashboardModel> getDashboard() async {
    final response = await _apiClient.get(ApiEndpoints.dashboard);
    return DashboardModel.fromJson(response.data);
  }

}
