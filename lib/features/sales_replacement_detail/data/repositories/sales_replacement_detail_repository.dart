import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../../../invoice_detail/data/models/invoice_detail_model.dart';
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
  Future<SalesReplacementDetailModel> getSalesReplacementDetail(
      String returnBillNo,
      ) async {
    final response = await _apiClient.get(
      ApiEndpoints.salesReplacementDetails(returnBillNo),
    );
    return SalesReplacementDetailModel.fromJson(response.data);
  }

  Future<InvoiceDetailModel> getInvoiceDetail(String id) async {
    final response = await _apiClient.get(ApiEndpoints.invoiceDetails(id));
    return InvoiceDetailModel.fromJson(response.data);
  }
}