import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';

final termsPrivacyRepositoryProvider = Provider<TermsPrivacyRepository>((ref) {
  return TermsPrivacyRepository(ref.watch(apiClientProvider));
});

class TermsPrivacyRepository {
  final ApiClient _apiClient;

  TermsPrivacyRepository(this._apiClient);
}
