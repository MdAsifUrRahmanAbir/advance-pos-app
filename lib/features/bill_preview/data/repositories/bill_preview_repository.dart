import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../models/sales_bill_preview_model.dart';

final billPreviewRepositoryProvider = Provider<BillPreviewRepository>((ref) {
  return BillPreviewRepository(ref.watch(apiClientProvider));
});

/// Thermal bill data shared by every flow that shows or prints a sales
/// bill (Invoices, Invoice Detail, Payment, Edit Sale).
class BillPreviewRepository {
  final ApiClient _apiClient;
  BillPreviewRepository(this._apiClient);

  // AUTO-GENERATED API METHOD
  Future<SalesBillPreviewModel> getSalesBillPreview(String billNo) async {
    final response = await _apiClient.get(ApiEndpoints.salesBillPreview(billNo));
    return SalesBillPreviewModel.fromJson(response.data);
  }
}