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
    int? groupId,
    int? categoryId,
    int? subCategoryId,
    int? brandId,
    int? customerId,
    int? employeeId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {

    _apiClient.setAuthToken("2nMDQU2TodIJH9Y8oycSUKNDVcHh5KZKCbLAmamU");

    final response = await _apiClient.get(
      ApiEndpoints.invoices,
      queryParameters: {
        'start': start,
        'length': length,
        if (search.isNotEmpty) 'search': search,
        // TODO: confirm these exact param names with the backend —
        // guessed as snake_case to match Stock's convention.
        'group_id': ?groupId,
        'category_id': ?categoryId,
        'sub_category_id': ?subCategoryId,
        'brand_id': ?brandId,
        'customer_id': ?customerId,
        'employee_id': ?employeeId,
        if (startDate != null && endDate != null) 'dateRange': "${_formatDate(startDate)} to ${_formatDate(endDate)}"
        // if (startDate != null) 'start_date': _formatDate(startDate),
        // if (endDate != null) 'end_date': _formatDate(endDate),
      },
    );
    return InvoicesModel.fromJson(response.data);
  }

  String _formatDate(DateTime date) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${date.day}-${two(date.month)}-${two(date.year)}';
  }
}

