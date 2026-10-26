import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_exception.dart';
import '../../../customers/data/models/customers_model.dart';
import '../../../invoice_detail/data/models/invoice_detail_model.dart';
import '../../../new_sale/data/models/stocks_model.dart';
import '../models/bills_model.dart';

final salesReplacementAddRepositoryProvider =
Provider<SalesReplacementAddRepository>((ref) {
  return SalesReplacementAddRepository(ref.watch(apiClientProvider));
});

class SalesReplacementAddRepository {
  final ApiClient _apiClient;
  SalesReplacementAddRepository(this._apiClient);

  /// GET /customer — the same endpoint the Customers screen uses.
  /// Cache policy: never.
  Future<CustomersModel> getCustomers({
    required int start,
    required int length,
    String search = '',
  }) async {
    final response = await _apiClient.get(
      ApiEndpoints.customers(length.toString()),
      queryParameters: {
        'start': start,
        if (search.isNotEmpty) 'search': search,
      },
    );
    return CustomersModel.fromJson(response.data);
  }

  /// GET /s_return/getData?context=getSalesBills — one page of sales bill
  /// numbers; request the next page while `hasMore` is true.
  /// Cache policy: never.
  Future<BillsModel> getSalesBills({
    required int branchId,
    String? customerNo,
    int page = 1,
  }) async {
    final response = await _apiClient.get(
      ApiEndpoints.salesReplacementBills,
      queryParameters: {
        'context': 'getSalesBills',
        'branch_id': branchId,
        'page': page,
        if (customerNo != null && customerNo.isNotEmpty) 'customer_no': customerNo,
      },
    );
    return BillsModel.fromJson(response.data);
  }

  /// GET /sales/view/{billNo} — the original sale being replaced.
  /// Cache policy: never.
  Future<InvoiceDetailModel> getInvoiceDetail(String billNo) async {
    final response = await _apiClient.get(ApiEndpoints.invoiceDetails(billNo));
    return InvoiceDetailModel.fromJson(response.data);
  }

  /// GET /product_stock — product search for the replacement items.
  /// Cache policy: never.
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

  /// POST /s_return/add — returns the new replacement's bill number.
  /// A 200 response whose `status` isn't "success" is raised as
  /// [ApiException] so it never shows up as a success.
  /// Cache policy: never.
  Future<String> createSalesReplacement(Map<String, dynamic> payload) async {
    final response = await _apiClient.post(
      ApiEndpoints.salesReplacementAdd,
      data: payload,
    );
    final data = response.data;
    final map = data is Map ? data : const {};
    final status = map['status']?.toString().toLowerCase();
    if (status != null && status != 'success') {
      throw ApiException(
        message: map['message']?.toString() ?? '',
        statusCode: response.statusCode,
      );
    }
    return (map['return_bill_no'] ?? map['id'])?.toString() ?? '';
  }
}