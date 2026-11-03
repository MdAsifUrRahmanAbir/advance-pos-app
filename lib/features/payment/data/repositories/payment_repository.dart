import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/session/api_params.dart';
import '../models/sales_success_model.dart';

final paymentRepositoryProvider = Provider<PaymentRepository>((ref) {
  return PaymentRepository(ref.watch(apiClientProvider));
});

class PaymentRepository {
  final ApiClient _apiClient;
  PaymentRepository(this._apiClient);

  // Payment systems / accounts come from master data
  // (MasterDataRepository) — only sale creation belongs here.

  /// POST /sales/add — creates the sale. The cart / payment fields are
  /// built by [PaymentController]; `sales_type`, `branch_id` and
  /// `employee_id` are set here from the cached [ApiParams].
  Future<SalesSuccessModel> completeSale(Map<String, dynamic> data) async {
    final params = ApiParams.current;
    final response = await _apiClient.post(
      ApiEndpoints.salesAdd,
      data: {
        'sales_type': '${params.salesType}',
        'branch_id': '${params.branchId}',
        'employee_id': '${params.employeeId}',
        ...data,
      },
    );
    return SalesSuccessModel.fromJson(response.data);
  }
}