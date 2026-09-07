import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../models/product_model.dart';

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepository(ref.watch(apiClientProvider));
});

class ProductRepository {
  final ApiClient _apiClient;
  ProductRepository(this._apiClient);



  // AUTO-GENERATED API METHOD
  Future<ProductModel> getProduct() async {
    final response = await _apiClient.get(ApiEndpoints.products);
    return ProductModel.fromJson(response.data);
  }

}
