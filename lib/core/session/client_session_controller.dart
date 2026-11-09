import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/api_endpoints.dart';
import '../network/api_client.dart';
import '../storage/local_cache_service.dart';
import '../storage/secure_storage_service.dart';
import 'client_profile.dart';

/// Single source of truth for "which company is this device bound to".
/// Owns the API base URL: every change here is pushed to [ApiClient], so
/// all repositories call the verified company's server.
class ClientSessionController extends Notifier<ClientProfile?> {
  SecureStorageService get _secureStorage =>
      ref.read(secureStorageServiceProvider);
  ApiClient get _apiClient => ref.read(apiClientProvider);

  @override
  ClientProfile? build() => null;

  /// Call once at startup, before restoring the auth session.
  Future<void> restore() async {
    final profile = ClientProfile.tryDecode(
      await _secureStorage.readClientProfile(),
    );
    if (profile == null) {
      await _secureStorage.clearClientProfile();
      _apiClient.setBaseUrl(ApiEndpoints.baseUrl);
      state = null;
      return;
    }
    _apiClient.setBaseUrl(profile.apiBaseUrl);
    state = profile;
  }

  /// After a successful company-code verification. Whatever a previously
  /// bound company left behind (its saved profile, remembered username and
  /// all cached data) is removed first, then the new company is saved.
  Future<void> save(ClientProfile profile) async {
    await _secureStorage.clearClientProfile();
    await _secureStorage.clearRememberedUsername();
    await ref.read(localCacheServiceProvider).clearOnLogout();
    await _secureStorage.saveClientProfile(profile.encode());
    _apiClient.setBaseUrl(profile.apiBaseUrl);
    state = profile;
  }

  /// "Switch company" on Login: forgets the company and drops cached data
  /// that belonged to it (master data etc. differ per company), including
  /// the username remembered for it. This is the only place the saved
  /// company info is removed.
  Future<void> clear() async {
    await _secureStorage.clearClientProfile();
    await _secureStorage.clearRememberedUsername();
    await ref.read(localCacheServiceProvider).clearOnLogout();
    _apiClient.setBaseUrl(ApiEndpoints.baseUrl);
    state = null;
  }
}

final clientSessionControllerProvider =
NotifierProvider<ClientSessionController, ClientProfile?>(
  ClientSessionController.new,
);