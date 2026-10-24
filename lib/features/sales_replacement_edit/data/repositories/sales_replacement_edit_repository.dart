import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';

final salesReplacementEditRepositoryProvider = Provider<SalesReplacementEditRepository>((ref) {
  return SalesReplacementEditRepository(ref.watch(apiClientProvider));
});

class SalesReplacementEditRepository {
  final ApiClient _apiClient;
  SalesReplacementEditRepository(this._apiClient);


}
