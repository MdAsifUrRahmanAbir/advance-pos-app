import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../models/customers_model.dart';

final customersRepositoryProvider = Provider<CustomersRepository>((ref) {
  return CustomersRepository(ref.watch(apiClientProvider));
});

class CustomersRepository {
  final ApiClient _apiClient;
  CustomersRepository(this._apiClient);

  /// Same `/customer` endpoint the Cart feature's customer picker uses
  /// (`ApiEndpoints.customers`) — copied here so this standalone
  /// Customers list screen doesn't depend on the `cart` feature.
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