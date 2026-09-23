import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:advance_pos_app/core/network/api_client.dart';
import 'package:advance_pos_app/core/constants/api_endpoints.dart';
import '../models/customers_model.dart';

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
}