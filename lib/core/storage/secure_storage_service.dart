import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Central, minimal wrapper around platform-backed secure storage
/// (Android Keystore / iOS Keychain). Use ONLY for small values:
/// auth tokens, refresh tokens, the signed-in user's session profile
/// (branch, employee, seller type, name), the Hive cache-encryption key.
/// Never store large payloads here — that's [LocalCacheService]'s job.
class SecureStorageService {
  final FlutterSecureStorage _storage;

  SecureStorageService()
      : _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  static const _keyAccessToken = 'auth_access_token';
  static const _keyRefreshToken = 'auth_refresh_token';
  static const _keySessionProfile = 'auth_session_profile';
  static const _keyCacheEncryptionKey = 'cache_encryption_key';
  static const _keyClientProfile = 'client_profile';
  static const _keyApiParams = 'auth_api_params';

  Future<void> saveAccessToken(String token) =>
      _storage.write(key: _keyAccessToken, value: token);
  Future<String?> readAccessToken() => _storage.read(key: _keyAccessToken);

  Future<void> saveRefreshToken(String token) =>
      _storage.write(key: _keyRefreshToken, value: token);
  Future<String?> readRefreshToken() => _storage.read(key: _keyRefreshToken);

  /// JSON string of the session profile (see SessionProfile.encode()).
  Future<void> saveSessionProfile(String json) =>
      _storage.write(key: _keySessionProfile, value: json);
  Future<String?> readSessionProfile() =>
      _storage.read(key: _keySessionProfile);
  Future<void> clearSessionProfile() =>
      _storage.delete(key: _keySessionProfile);

  /// JSON string of the request params (see ApiParams.encode()):
  /// branch_id, employee_id, sales_type cached after login.
  Future<void> saveApiParams(String json) =>
      _storage.write(key: _keyApiParams, value: json);
  Future<String?> readApiParams() => _storage.read(key: _keyApiParams);
  Future<void> clearApiParams() => _storage.delete(key: _keyApiParams);

  Future<String?> readCacheEncryptionKey() =>
      _storage.read(key: _keyCacheEncryptionKey);
  Future<void> saveCacheEncryptionKey(String key) =>
      _storage.write(key: _keyCacheEncryptionKey, value: key);


  /// JSON string of the verified company (see ClientProfile.encode()).
  /// Kept across logout: the device stays bound to the company.
  Future<void> saveClientProfile(String json) =>
      _storage.write(key: _keyClientProfile, value: json);
  Future<String?> readClientProfile() => _storage.read(key: _keyClientProfile);
  Future<void> clearClientProfile() => _storage.delete(key: _keyClientProfile);
  
  /// Called on logout. Wipes tokens only (the session profile is cleared
  /// separately via [clearSessionProfile]).
  Future<void> clearAuthTokens() async {
    await _storage.delete(key: _keyAccessToken);
    await _storage.delete(key: _keyRefreshToken);
  }

  Future<void> clearAll({bool includeCacheKey = false}) async {
    await clearAuthTokens();
    await clearSessionProfile();
    await clearApiParams();
    if (includeCacheKey) {
      await _storage.delete(key: _keyCacheEncryptionKey);
    }
  }
}

final secureStorageServiceProvider = Provider<SecureStorageService>(
      (ref) => SecureStorageService(),
);