import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../network/api_client.dart';
import '../storage/secure_storage_service.dart';
import '../storage/local_cache_service.dart';
import 'api_params.dart';
import 'auth_session_state.dart';
import 'session_profile.dart';

/// Single source of truth for "is someone logged in right now". Read this
/// from the splash flow to pick the initial route. Never duplicate a
/// session check anywhere else — everything routes through here.
///
/// A session is the saved [SessionProfile]. The login API currently
/// returns no token, so the access token is optional: when the backend
/// starts returning one, pass it to [onLoginSuccess] and it is sent as
/// `Bearer` automatically.
class AuthSessionController extends Notifier<AuthSessionState> {
  SecureStorageService get _secureStorage =>
      ref.read(secureStorageServiceProvider);
  ApiClient get _apiClient => ref.read(apiClientProvider);

  @override
  AuthSessionState build() => const AuthSessionState();

  /// Call once at startup. Restores the profile and the cached request
  /// params (branch, employee, sales type). Either one missing means
  /// signed out: no API call can be made without the params.
  Future<void> restoreSession() async {
    final profile = SessionProfile.tryDecode(
      await _secureStorage.readSessionProfile(),
    );
    final params =
        await ref.read(apiParamsControllerProvider.notifier).restore();

    if (profile == null || params == null) {
      await _secureStorage.clearAuthTokens();
      await _secureStorage.clearSessionProfile();
      await ref.read(apiParamsControllerProvider.notifier).clear();
      _apiClient.setAuthToken(null);
      state = state.copyWith(status: AuthStatus.unauthenticated);
      return;
    }

    final token = await _secureStorage.readAccessToken();
    final hasToken = token != null && token.isNotEmpty;
    _apiClient.setAuthToken(hasToken ? token : null);
    state = AuthSessionState(
      status: AuthStatus.authenticated,
      accessToken: hasToken ? token : null,
      profile: profile,
    );
  }

  Future<void> onLoginSuccess({
    String? accessToken,
    String? refreshToken,
    required SessionProfile profile,
  }) async {
    final hasToken = accessToken != null && accessToken.isNotEmpty;

    // Drop any token left by an older session before saving the new one.
    await _secureStorage.clearAuthTokens();
    if (hasToken) {
      await _secureStorage.saveAccessToken(accessToken);
      if (refreshToken != null && refreshToken.isNotEmpty) {
        await _secureStorage.saveRefreshToken(refreshToken);
      }
    }
    await _secureStorage.saveSessionProfile(profile.encode());
    _apiClient.setAuthToken(hasToken ? accessToken : null);
    state = AuthSessionState(
      status: AuthStatus.authenticated,
      accessToken: hasToken ? accessToken : null,
      profile: profile,
    );
  }

  /// Persists a change to the signed-in user's profile. No-op when
  /// signed out. (A branch switch goes through `apiParamsControllerProvider`.)
  Future<void> updateProfile(SessionProfile profile) async {
    if (!state.isLoggedIn) return;
    await _secureStorage.saveSessionProfile(profile.encode());
    state = state.copyWith(profile: profile);
  }

  Future<void> logout() async {
    await _secureStorage.clearAuthTokens();
    await _secureStorage.clearSessionProfile();
    await ref.read(apiParamsControllerProvider.notifier).clear();
    _apiClient.setAuthToken(null);
    await ref.read(localCacheServiceProvider).clearOnLogout();
    state = const AuthSessionState(status: AuthStatus.unauthenticated);
  }
}

final authSessionControllerProvider =
NotifierProvider<AuthSessionController, AuthSessionState>(
  AuthSessionController.new,
);

/// Signed-in user's profile, or null when signed out.
final sessionProfileProvider = Provider<SessionProfile?>(
      (ref) => ref.watch(authSessionControllerProvider.select((s) => s.profile)),
);

// Branch / employee / sales type: use `apiParamsProvider` in api_params.dart.