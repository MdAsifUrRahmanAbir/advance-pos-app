import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Central, minimal wrapper around platform-backed secure storage
/// (Android Keystore / iOS Keychain). Use ONLY for small, sensitive
/// values: auth tokens, refresh tokens, the Hive cache-encryption key.
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
  static const _keyCacheEncryptionKey = 'cache_encryption_key';

  Future<void> saveAccessToken(String token) =>
      _storage.write(key: _keyAccessToken, value: token);
  Future<String?> readAccessToken() => _storage.read(key: _keyAccessToken);

  Future<void> saveRefreshToken(String token) =>
      _storage.write(key: _keyRefreshToken, value: token);
  Future<String?> readRefreshToken() => _storage.read(key: _keyRefreshToken);

  Future<String?> readCacheEncryptionKey() =>
      _storage.read(key: _keyCacheEncryptionKey);
  Future<void> saveCacheEncryptionKey(String key) =>
      _storage.write(key: _keyCacheEncryptionKey, value: key);

  /// Called on logout. Wipes tokens only.
  Future<void> clearAuthTokens() async {
    await _storage.delete(key: _keyAccessToken);
    await _storage.delete(key: _keyRefreshToken);
  }

  /// "Clear all app data" / account-deletion flow. Pass
  /// [includeCacheKey]: true to also rotate the cache-encryption key,
  /// which permanently invalidates every encrypted cache entry.
  Future<void> clearAll({bool includeCacheKey = false}) async {
    await clearAuthTokens();
    if (includeCacheKey) {
      await _storage.delete(key: _keyCacheEncryptionKey);
    }
  }
}

final secureStorageServiceProvider =
Provider<SecureStorageService>((ref) => SecureStorageService());