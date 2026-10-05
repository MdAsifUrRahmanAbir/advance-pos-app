import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:advance_pos_app/core/network/api_client.dart';
import 'package:advance_pos_app/core/constants/api_endpoints.dart';
import '../models/customers_model.dart';
import '../models/add_customer_model.dart';
import '../models/get_discount.dart';

final cartRepositoryProvider = Provider<CartRepository>((ref) {
  return CartRepository(ref.watch(apiClientProvider));
});

class CartRepository {
  final ApiClient _apiClient;
  CartRepository(this._apiClient);

  /// Searchable, paginated customer list for [CustomerSearchSheet].
  /// `length` is already baked into [ApiEndpoints.customers], so it's
  /// passed there rather than duplicated inside `queryParameters` —
  /// only `start`/`search` get added on top (same convention as
  /// [NewSaleRepository.getProducts] with `ApiEndpoints.stocks`).
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

  /// POST /customer/add — creates a new customer from [AddCustomerSheet].
  /// `branchId`/`customerType` are static for now per current scope
  /// (branch 2, type "1" = Retail Sales) — wire these to real selectors
  /// once multi-branch / type-choice is needed on this form.
  Future<AddCustomerModel> createCustomer({
    required String customerName,
    required String customerMobile,
    String customerEmail = '',
    String address = '',
    int branchId = 2,
    String customerType = '1',
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.customerAdd,
      data: {
        'branch_id': branchId,
        'customer_name': customerName,
        'customer_mobile': customerMobile,
        'customer_email': customerEmail,
        'customer_type': customerType,
        'par_remarks': address,
      },
    );
    return AddCustomerModel.fromJson(response.data);
  }

  /// GET /get_discount with a JSON body (same contract as the web
  /// `GetDiscount` call). [amounts] are UNIT prices, parallel to
  /// [productIds] and [quantities].
  Future<GetDiscountModel> getGetDiscount({
    required String customerId,
    required List<double> amounts,
    required List<String> productIds,
    required List<int> quantities,
    String? discountType, // 'product' | 'bill' — only when scope is "both"
    int branchId = 2,
    int salesType = 1,
    DateTime? salesDate,
  }) async {
    final d = salesDate ?? DateTime.now();
    String two(int n) => n.toString().padLeft(2, '0');

    final response = await _apiClient.get(
      ApiEndpoints.getDiscount,
      data: {
        'customerId': int.tryParse(customerId) ?? customerId,
        'amount': amounts,
        'Product': [for (final id in productIds) int.tryParse(id) ?? id],
        'Qnt': quantities,
        'sales_type': salesType,
        'sales_date': '${d.year}-${two(d.month)}-${two(d.day)}',
        'branch_id': branchId,
        'discountType': ?discountType,
      },
    );
    return GetDiscountModel.fromJson(response.data);
  }

}
