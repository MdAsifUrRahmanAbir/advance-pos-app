import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../../../master_data/data/models/common_success_model.dart';
import '../models/sales_return_model.dart';

final salesReturnRepositoryProvider = Provider<SalesReturnRepository>((ref) {
  return SalesReturnRepository(ref.watch(apiClientProvider));
});

class SalesReturnRepository {
  final ApiClient _apiClient;
  SalesReturnRepository(this._apiClient);


  Future<SalesReturnModel> getSalesReturns({
    required int start,
    required int length,
    required int branchId,
    String? search,
    String? dateRange,
  }) async {
    final response = await _apiClient.get(
      ApiEndpoints.salesReturn,
      queryParameters: {
        'start': start,
        'length': length,
        'branchId': branchId,
        if (search != null && search.isNotEmpty) 'search[value]': search,
        'dateRange': ?dateRange,
      },
    );
    return SalesReturnModel.fromJson(response.data);
  }

  Future<CommonSuccessModel> deleteSalesReturn(String returnBillNo) async {
    final response = await _apiClient.delete(
      ApiEndpoints.salesReturnDelete(returnBillNo),
    );
    return CommonSuccessModel.fromJson(response.data);
  }
}