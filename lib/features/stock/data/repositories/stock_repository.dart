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

  Future<StocksModel> getStocks({
    required int start,
    required int length,
    String search = '',
    int? supplierId,
    int? groupId,
    int? categoryId,
    int? subCategoryId,
    int? brandId,
  }) async {
    final response = await _apiClient.get(
      ApiEndpoints.stocks,
      queryParameters: {
        'start': start,
        'length': length,
        if (search.isNotEmpty) 'search': search,
        'supplier_id': ?supplierId,
        'prod_group_id': ?groupId,
        'prod_cat_id': ?categoryId,
        'prod_sub_cat_id': ?subCategoryId,
        'prod_brand_id': ?brandId,
      },
    );
    return StocksModel.fromJson(response.data);
  }
}