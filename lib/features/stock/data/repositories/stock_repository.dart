import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../models/stocks_model.dart';

final stockRepositoryProvider = Provider<StockRepository>((ref) {
  return StockRepository(ref.watch(apiClientProvider));
});

class StockRepository {
  final ApiClient _apiClient;
  StockRepository(this._apiClient);

  static const int pageLength = 15;

  // AUTO-GENERATED API METHOD (patched: added pagination params)
  Future<StocksModel> getStocks({int start = 0, int length = pageLength}) async {
    final response = await _apiClient.get(ApiEndpoints.stocks, queryParameters: {
      "start": "$start",
      "length": "$length",
    });
    return StocksModel.fromJson(response.data);
  }
}