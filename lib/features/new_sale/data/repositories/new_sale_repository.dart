import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';

final newSaleRepositoryProvider = Provider<NewSaleRepository>((ref) {
  return NewSaleRepository(ref.watch(apiClientProvider));
});

class NewSaleRepository {
  final ApiClient _apiClient;
  NewSaleRepository(this._apiClient);


}
