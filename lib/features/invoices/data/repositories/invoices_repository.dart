import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../model/invoices_model.dart';

final invoicesRepositoryProvider = Provider<InvoicesRepository>((ref) {
  return InvoicesRepository(ref.watch(apiClientProvider));
});

class InvoicesRepository {
  final ApiClient _apiClient;
  InvoicesRepository(this._apiClient);

  Future<InvoicesModel> getInvoices({
    required int start,
    required int length,
    String search = '',
  }) async {
    _apiClient.setAuthToken("2nMDQU2TodIJH9Y8oycSUKNDVcHh5KZKCbLAmamU");

    final response = await _apiClient.get(
      ApiEndpoints.invoices,
      queryParameters: {
        'start': start,
        'length': length,
        if (search.isNotEmpty) 'search': search,
      },
    );
    return InvoicesModel.fromJson(response.data);
  }
}
