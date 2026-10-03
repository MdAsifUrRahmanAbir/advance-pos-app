import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../models/sales_success_model.dart';

final paymentRepositoryProvider = Provider<PaymentRepository>((ref) {
  return PaymentRepository(ref.watch(apiClientProvider));
});

class PaymentRepository {
  final ApiClient _apiClient;
  PaymentRepository(this._apiClient);

  // Payment systems / accounts come from master data
  // (MasterDataRepository) — only sale creation belongs here.

  /// POST /sales/add — creates the sale. The payload is built by
  /// [PaymentController] (it owns the cart + payment selection).
  Future<SalesSuccessModel> completeSale(Map<String, dynamic> data) async {
    final response = await _apiClient.post(ApiEndpoints.salesAdd, data: data);
    return SalesSuccessModel.fromJson(response.data);
  }
}