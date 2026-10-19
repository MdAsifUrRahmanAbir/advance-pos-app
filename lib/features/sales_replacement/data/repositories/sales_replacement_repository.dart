import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../models/sales_replacement_model.dart';

final salesReplacementRepositoryProvider =
Provider<SalesReplacementRepository>((ref) {
  return SalesReplacementRepository(ref.watch(apiClientProvider));
});

class SalesReplacementRepository {
  final ApiClient _apiClient;
  SalesReplacementRepository(this._apiClient);

  /// GET /s_return
  /// Cache policy: never (transactional data).
  Future<SalesReplacementModel> getSalesReplacements({
    required int start,
    required int length,
    required int branchId,
    String? search,
    String? dateRange,
  }) async {
    final response = await _apiClient.get(
      ApiEndpoints.salesReplacement,
      queryParameters: {
        'start': start,
        'length': length,
        'branchId': branchId,
        if (search != null && search.isNotEmpty) 'search[value]': search,
        'dateRange': ?dateRange,
      },
    );
    return SalesReplacementModel.fromJson(response.data);
  }

  /// DELETE /s_return/delete/{id}
  /// Cache policy: never.
  ///
  /// The response carries only `message` (no `status`), so the shared
  /// `CommonSuccessModel` can't parse it. Returns the server message.
  Future<String> deleteSalesReplacement(String returnBillNo) async {
    final response = await _apiClient.delete(
      ApiEndpoints.salesReplacementDelete(returnBillNo),
    );
    final data = response.data;
    return data is Map && data['message'] != null
        ? data['message'].toString()
        : '';
  }
}