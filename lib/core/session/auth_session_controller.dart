import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../network/api_client.dart';
import '../storage/secure_storage_service.dart';
import '../storage/local_cache_service.dart';
import 'auth_session_state.dart';

/// Single source of truth for "is someone logged in right now". Read this
/// from the splash flow to pick the initial route. Never duplicate a
/// token check anywhere else — everything routes through here.
class AuthSessionController extends Notifier<AuthSessionState> {
  SecureStorageService get _secureStorage => ref.read(secureStorageServiceProvider);
  ApiClient get _apiClient => ref.read(apiClientProvider);

  @override
  AuthSessionState build() => const AuthSessionState();

  /// Call once at startup. This only checks that a token exists locally —
  /// pair it with a lightweight `/auth/me` repository call if you need
  /// server-side validation (expired/revoked tokens), not just presence.
  Future<void> restoreSession() async {
    final token = await _secureStorage.readAccessToken();
    if (token == null || token.isEmpty) {
      state = state.copyWith(status: AuthStatus.unauthenticated);
      return;
    }
    _apiClient.setAuthToken(token);
    state = AuthSessionState(status: AuthStatus.authenticated, accessToken: token);
  }

  Future<void> onLoginSuccess({required String accessToken, String? refreshToken}) async {
    await _secureStorage.saveAccessToken(accessToken);
    if (refreshToken != null) await _secureStorage.saveRefreshToken(refreshToken);
    _apiClient.setAuthToken(accessToken);
    state = AuthSessionState(status: AuthStatus.authenticated, accessToken: accessToken);
  }

  Future<void> logout() async {
    await _secureStorage.clearAuthTokens();
    _apiClient.setAuthToken(null);
    await ref.read(localCacheServiceProvider).clearOnLogout();
    state = const AuthSessionState(status: AuthStatus.unauthenticated);
  }
}

final authSessionControllerProvider =
NotifierProvider<AuthSessionController, AuthSessionState>(AuthSessionController.new);