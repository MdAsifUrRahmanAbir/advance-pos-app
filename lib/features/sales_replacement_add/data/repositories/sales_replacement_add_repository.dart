import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';

final salesReplacementAddRepositoryProvider = Provider<SalesReplacementAddRepository>((ref) {
  return SalesReplacementAddRepository(ref.watch(apiClientProvider));
});

class SalesReplacementAddRepository {
  final ApiClient _apiClient;
  SalesReplacementAddRepository(this._apiClient);


}
