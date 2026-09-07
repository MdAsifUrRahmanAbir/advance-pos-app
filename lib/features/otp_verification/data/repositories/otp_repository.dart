import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:template_test/core/network/api_client.dart';

final otpRepositoryProvider = Provider<OtpRepository>((ref) {
  return OtpRepository(ref.watch(apiClientProvider));
});

class OtpRepository {
  final ApiClient _apiClient;
  OtpRepository(this._apiClient);
}
