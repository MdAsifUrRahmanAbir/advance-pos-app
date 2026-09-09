import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';

final invoicesRepositoryProvider = Provider<InvoicesRepository>((ref) {
  return InvoicesRepository(ref.watch(apiClientProvider));
});

class InvoicesRepository {
  final ApiClient _apiClient;
  InvoicesRepository(this._apiClient);


}
