import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../models/stock_model.dart';

final stockRepositoryProvider = Provider<StockRepository>((ref) {
  return StockRepository(ref.watch(apiClientProvider));
});

class StockRepository {
  final ApiClient _apiClient;
  StockRepository(this._apiClient);



  // AUTO-GENERATED API METHOD
  Future<StockModel> getProduct() async {
    final response = await _apiClient.get(ApiEndpoints.products);
    return StockModel.fromJson(response.data);
  }

}
