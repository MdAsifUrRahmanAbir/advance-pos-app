import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';

final orderListRepositoryProvider = Provider<OrderListRepository>((ref) {
  return OrderListRepository(ref.watch(apiClientProvider));
});

class OrderListRepository {
  final ApiClient _apiClient;

  OrderListRepository(this._apiClient);
}
