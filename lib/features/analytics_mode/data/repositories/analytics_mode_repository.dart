import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';

final analyticsModeRepositoryProvider = Provider<AnalyticsModeRepository>((ref) {
  return AnalyticsModeRepository(ref.watch(apiClientProvider));
});

class AnalyticsModeRepository {
  final ApiClient _apiClient;

  AnalyticsModeRepository(this._apiClient);
}
