import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../models/sales_replacement_detail_model.dart';

final salesReplacementDetailRepositoryProvider =
Provider<SalesReplacementDetailRepository>((ref) {
  return SalesReplacementDetailRepository(ref.watch(apiClientProvider));
});

class SalesReplacementDetailRepository {
  final ApiClient _apiClient;
  SalesReplacementDetailRepository(this._apiClient);

  /// GET /s_return/view/{id}
  /// Cache policy: never (transactional data).
  Future<SalesReplacmentDetailModel> getSalesReplacementDetail(
      String returnBillNo,
      ) async {
    final response = await _apiClient.get(
      ApiEndpoints.salesReplacementDetails(returnBillNo),
    );
    return SalesReplacmentDetailModel.fromJson(response.data);
  }
}