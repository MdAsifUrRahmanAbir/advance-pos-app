import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'cache_entry.dart';
import 'cache_policy.dart';
import 'secure_storage_service.dart';

/// Generic key-value cache with TTL support, backed by two Hive boxes:
/// - `app_cache_standard` — plain, for [CacheSensitivity.standard] data.
/// - `app_cache_secure`   — AES-encrypted with a key held in the platform
///   keystore/keychain, for [CacheSensitivity.sensitive] data.
///
/// [CacheSensitivity.none] never touches this service — callers simply
/// don't cache it.
class LocalCacheService {
  static const _standardBoxName = 'app_cache_standard';
  static const _secureBoxName = 'app_cache_secure';

  late Box _standardBox;
  late Box _secureBox;
  bool _initialized = false;

  final SecureStorageService _secureStorage;
  LocalCacheService(this._secureStorage);

  Future<void> init() async {
    if (_initialized) return;
    await Hive.initFlutter();

    _standardBox = await Hive.openBox(_standardBoxName);

    final cipher = await _resolveCipher();
    _secureBox = await Hive.openBox(_secureBoxName, encryptionCipher: cipher);

    _initialized = true;
  }

  Future<HiveAesCipher> _resolveCipher() async {
    var keyString = await _secureStorage.readCacheEncryptionKey();
    if (keyString == null) {
      final newKey = Hive.generateSecureKey();
      keyString = base64UrlEncode(newKey);
      await _secureStorage.saveCacheEncryptionKey(keyString);
    }
    return HiveAesCipher(base64Url.decode(keyString));
  }

  Box _boxFor(CacheSensitivity sensitivity) =>
      sensitivity == CacheSensitivity.sensitive ? _secureBox : _standardBox;

  Future<void> write<T>(
      String key,
      T data,
      CachePolicy policy,
      Map<String, dynamic> Function(T) toJsonT,
      ) async {
    if (policy.sensitivity == CacheSensitivity.none) return; // no-op by design
    final entry = CacheEntry<T>(data: data, cachedAt: DateTime.now(), ttl: policy.ttl);
    await _boxFor(policy.sensitivity).put(key, jsonEncode(entry.toJson(toJsonT)));
  }

  T? read<T>(
      String key,
      CacheSensitivity sensitivity,
      T Function(Map<String, dynamic>) fromJsonT,
      ) {
    final raw = _boxFor(sensitivity).get(key) as String?;
    if (raw == null) return null;
    final entry = CacheEntry.fromJson<T>(jsonDecode(raw) as Map<String, dynamic>, fromJsonT);
    if (entry.isExpired) {
      _boxFor(sensitivity).delete(key);
      return null;
    }
    return entry.data;
  }

  Future<void> invalidate(String key, CacheSensitivity sensitivity) =>
      _boxFor(sensitivity).delete(key);

  /// Called on logout. Sensitive cache is always cleared; standard cache
  /// only if [clearStandard] is true — you may deliberately want to keep,
  /// say, a cached product catalog across accounts on a shared device.
  /// Decide per app and document the choice here.
  Future<void> clearOnLogout({bool clearStandard = true}) async {
    await _secureBox.clear();
    if (clearStandard) await _standardBox.clear();
  }
}

/// Overridden in main.dart once `LocalCacheService.init()` has completed —
/// see §15.10. The throw is intentional: it fails loudly if something
/// reads this provider before startup init has run.
final localCacheServiceProvider = Provider<LocalCacheService>((ref) {
  throw UnimplementedError('Override with an initialized LocalCacheService in main.dart.');
});