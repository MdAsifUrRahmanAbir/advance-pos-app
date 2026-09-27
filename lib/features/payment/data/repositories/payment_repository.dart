import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../models/payment_accounts_model.dart' as pa;
import '../models/payment_system_model.dart' as ps;

final paymentRepositoryProvider = Provider<PaymentRepository>((ref) {
  return PaymentRepository(ref.watch(apiClientProvider));
});

class PaymentRepository {
  final ApiClient _apiClient;
  PaymentRepository(this._apiClient);

  /// GET /gnl/payment_system/all — every configured payment method
  /// (Cash, Bank, bKash, ...). No pagination params; the endpoint
  /// returns the full list.
  Future<ps.PaymentSystemModel> getPaymentSystems() async {
    final response = await _apiClient.get(ApiEndpoints.paymentSystem);
    return ps.PaymentSystemModel.fromJson(response.data);
  }

  /// GET /gnl/payment_account/all — every configured account (bank
  /// account, mobile-banking merchant number, etc.), each tagged with
  /// its owning payment system.
  Future<pa.PaymentAccountsModel> getPaymentAccounts() async {
    final response = await _apiClient.get(ApiEndpoints.paymentAccount);
    return pa.PaymentAccountsModel.fromJson(response.data);
  }
}