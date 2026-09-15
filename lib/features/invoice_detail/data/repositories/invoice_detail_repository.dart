import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../models/invoice_detail_model.dart';

final invoiceDetailRepositoryProvider = Provider<InvoiceDetailRepository>((
  ref,
) {
  return InvoiceDetailRepository(ref.watch(apiClientProvider));
});

class InvoiceDetailRepository {
  final ApiClient _apiClient;
  InvoiceDetailRepository(this._apiClient);

  /// [id] is the sales bill number (e.g. `salesBillNo` from the
  /// Invoices list), matching what the list screen passes via
  /// `context.push(RouteNames.invoiceDetail, extra: invoice.salesBillNo)`.
  Future<InvoiceDetailModel> getInvoiceDetail(String id) async {
    final response = await _apiClient.get(ApiEndpoints.invoiceDetails(id));
    return InvoiceDetailModel.fromJson(response.data);
  }
}
