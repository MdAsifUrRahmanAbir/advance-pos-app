import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';

final paymentRepositoryProvider = Provider<PaymentRepository>((ref) {
  return PaymentRepository(ref.watch(apiClientProvider));
});

class PaymentRepository {
  final ApiClient _apiClient;
  PaymentRepository(this._apiClient);

// Payment systems / accounts now come from master data
// (MasterDataRepository) — only sale creation belongs here.
// TODO: Future<...> completeSale(...) → ApiEndpoints.salesAdd
}