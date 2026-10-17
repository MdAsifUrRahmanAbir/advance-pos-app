import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_exception.dart';
import '../models/edit_sale_success_model.dart';

final editSalePaymentRepositoryProvider = Provider<EditSalePaymentRepository>((ref) {
  return EditSalePaymentRepository(ref.watch(apiClientProvider));
});

class EditSalePaymentRepository {
  final ApiClient _apiClient;
  EditSalePaymentRepository(this._apiClient);

  /// PUT /sales/edit/:billNo — replaces the sale's lines, customer and
  /// payments. The payload is built by `EditSalePaymentController`.
  /// A 200 response with `alert-type: error` is raised as [ApiException]
  /// so it never shows up as a success.
  Future<EditSaleSuccessModel> updateSale(String billNo, Map<String, dynamic> data) async {
    final response = await _apiClient.put(ApiEndpoints.salesEdit(billNo), data: data);
    final result = EditSaleSuccessModel.fromJson(response.data as Map<String, dynamic>);
    if (result.isError) {
      throw ApiException(message: result.message, statusCode: response.statusCode);
    }
    return result;
  }
}