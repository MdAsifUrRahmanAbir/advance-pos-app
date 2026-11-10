import 'package:advance_pos_app/core/storage/secure_storage_service.dart';

/// In-memory secure storage. Survives a simulated app restart when the
/// same instance is passed to the next pump. Starts with a client token,
/// like a device whose company is already verified.
class FakeSecureStorage implements SecureStorageService {
  FakeSecureStorage({String? clientToken = 'test-client-token'}) {
    if (clientToken != null) values[_clientToken] = clientToken;
  }

  final Map<String, String> values = {};

  static const _access = 'access';
  static const _refresh = 'refresh';
  static const _profile = 'profile';
  static const _params = 'params';
  static const _cacheKey = 'cacheKey';
  static const _client = 'client';
  static const _clientToken = 'clientToken';
  static const _username = 'username';
  static const _rememberSession = 'rememberSession';

  String? get rememberedUsername => values[_username];
  String? get sessionProfile => values[_profile];
  String? get apiParams => values[_params];
  String? get clientToken => values[_clientToken];
  bool get sessionRemembered => values.containsKey(_rememberSession);

  Future<void> _write(String k, String v) async => values[k] = v;
  Future<String?> _read(String k) async => values[k];
  Future<void> _delete(String k) async => values.remove(k);

  @override
  Future<void> saveAccessToken(String token) => _write(_access, token);
  @override
  Future<String?> readAccessToken() => _read(_access);
  @override
  Future<void> saveRefreshToken(String token) => _write(_refresh, token);
  @override
  Future<String?> readRefreshToken() => _read(_refresh);
  @override
  Future<void> saveSessionProfile(String json) => _write(_profile, json);
  @override
  Future<String?> readSessionProfile() => _read(_profile);
  @override
  Future<void> clearSessionProfile() => _delete(_profile);
  @override
  Future<void> saveApiParams(String json) => _write(_params, json);
  @override
  Future<String?> readApiParams() => _read(_params);
  @override
  Future<void> clearApiParams() => _delete(_params);
  @override
  Future<String?> readCacheEncryptionKey() => _read(_cacheKey);
  @override
  Future<void> saveCacheEncryptionKey(String key) => _write(_cacheKey, key);
  @override
  Future<void> saveClientProfile(String json) => _write(_client, json);
  @override
  Future<String?> readClientProfile() => _read(_client);
  @override
  Future<void> clearClientProfile() => _delete(_client);
  @override
  Future<void> saveClientToken(String token) => _write(_clientToken, token);
  @override
  Future<String?> readClientToken() => _read(_clientToken);
  @override
  Future<void> clearClientToken() => _delete(_clientToken);
  @override
  Future<void> saveRememberedUsername(String username) =>
      _write(_username, username);
  @override
  Future<String?> readRememberedUsername() => _read(_username);
  @override
  Future<void> clearRememberedUsername() => _delete(_username);
  @override
  Future<void> saveRememberSession(bool remember) =>
      remember ? _write(_rememberSession, '1') : _delete(_rememberSession);
  @override
  Future<bool> readRememberSession() async =>
      values.containsKey(_rememberSession);
  @override
  Future<void> clearRememberSession() => _delete(_rememberSession);

  @override
  Future<void> clearAuthTokens() async {
    values
      ..remove(_access)
      ..remove(_refresh);
  }

  @override
  Future<void> clearAll({bool includeCacheKey = false}) async {
    await clearAuthTokens();
    await clearSessionProfile();
    await clearApiParams();
    await clearRememberSession();
    if (includeCacheKey) values.remove(_cacheKey);
  }
}