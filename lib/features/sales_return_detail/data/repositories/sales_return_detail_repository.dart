import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../models/sales_return_detail_model.dart';

final salesReturnDetailRepositoryProvider =
Provider<SalesReturnDetailRepository>((ref) {
  return SalesReturnDetailRepository(ref.watch(apiClientProvider));
});

class SalesReturnDetailRepository {
  final ApiClient _apiClient;
  SalesReturnDetailRepository(this._apiClient);

  /// GET /sales_return/view/{id}
  /// Cache policy: never (transactional data).
  Future<SalesReturnDetailModel> getSalesReturnDetail(String id) async {
    final response = await _apiClient.get(
      ApiEndpoints.salesReturnDetails(id),
    );
    return SalesReturnDetailModel.fromJson(response.data);
  }
}