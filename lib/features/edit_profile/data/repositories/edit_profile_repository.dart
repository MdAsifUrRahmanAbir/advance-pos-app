import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';

final editProfileRepositoryProvider = Provider<EditProfileRepository>((ref) {
  return EditProfileRepository(ref.watch(apiClientProvider));
});

class EditProfileRepository {
  final ApiClient _apiClient;

  EditProfileRepository(this._apiClient);
}
