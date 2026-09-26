import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../models/stocks_model.dart';

final newSaleRepositoryProvider = Provider<NewSaleRepository>((ref) {
  return NewSaleRepository(ref.watch(apiClientProvider));
});

class NewSaleRepository {
  final ApiClient _apiClient;
  NewSaleRepository(this._apiClient);

  /// New Sale now sources its product list from the same
  /// product_stock endpoint Stock uses (`ApiEndpoints.stocks`) — same
  /// underlying catalog, so a product picked in New Sale reflects
  /// current stock levels for branch 2.
  Future<StocksModel> getProducts({
    required int start,
    required int length,
    String search = '',
    int? categoryId,
  }) async {
    final response = await _apiClient.get(
      ApiEndpoints.stocks(branchId: 2),
      queryParameters: {
        'start': start,
        'length': length,
        if (search.isNotEmpty) 'search': search,
        'category_id': ?categoryId,
      },
    );
    return StocksModel.fromJson(response.data);
  }
}