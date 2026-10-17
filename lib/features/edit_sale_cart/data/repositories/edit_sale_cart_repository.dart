import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../../../invoice_detail/data/models/invoice_detail_model.dart';
import '../../../new_sale/data/models/stocks_model.dart';
import '../models/edit_sale_source.dart';

final editSaleCartRepositoryProvider = Provider<EditSaleCartRepository>((ref) {
  return EditSaleCartRepository(ref.watch(apiClientProvider));
});

/// Data access for the Edit Sale cart.
///
/// Customer search/creation and `/get_discount` are NOT duplicated here —
/// the controller reuses `CartRepository` for those (read-only reuse, the
/// cart feature itself is untouched).
class EditSaleCartRepository {
  final ApiClient _apiClient;
  EditSaleCartRepository(this._apiClient);

  /// GET /sales/view/:billNo — the invoice being edited.
  Future<EditSaleSource> getInvoiceForEdit(String billNo) async {
    final response = await _apiClient.get(ApiEndpoints.invoiceDetails(billNo));
    final json = response.data as Map<String, dynamic>;
    final raw = json['resultData'];
    String? customerNo;
    if (raw is Map<String, dynamic>) {
      final value = raw['customer_no'] ?? raw['customer_id'];
      if (value != null && value.toString().trim().isNotEmpty) {
        customerNo = value.toString().trim();
      }
    }
    return EditSaleSource(
      detail: InvoiceDetailModel.fromJson(json),
      customerNo: customerNo,
    );
  }

  /// Product search for the "add product" bar and the barcode scanner.
  /// Same `product_stock` endpoint New Sale uses, but with the signed-in
  /// user's branch instead of a hardcoded one.
  Future<StocksModel> searchProducts({
    required int branchId,
    required String search,
    int start = 0,
    int length = 20,
  }) async {
    final response = await _apiClient.get(
      ApiEndpoints.stocks(branchId: branchId),
      queryParameters: {
        'start': start,
        'length': length,
        if (search.isNotEmpty) 'search': search,
      },
    );
    return StocksModel.fromJson(response.data);
  }
}