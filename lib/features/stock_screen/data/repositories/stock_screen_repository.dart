import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';

final stockScreenRepositoryProvider = Provider<StockScreenRepository>((ref) {
  return StockScreenRepository(ref.watch(apiClientProvider));
});

class StockScreenRepository {
  final ApiClient _apiClient;
  StockScreenRepository(this._apiClient);


}
