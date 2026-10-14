import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../network/api_client.dart';
import '../storage/secure_storage_service.dart';
import '../storage/local_cache_service.dart';
import 'auth_session_state.dart';
import 'session_profile.dart';

/// Single source of truth for "is someone logged in right now". Read this
/// from the splash flow to pick the initial route. Never duplicate a
/// token check anywhere else — everything routes through here.
class AuthSessionController extends Notifier<AuthSessionState> {
  SecureStorageService get _secureStorage =>
      ref.read(secureStorageServiceProvider);
  ApiClient get _apiClient => ref.read(apiClientProvider);

  @override
  AuthSessionState build() => const AuthSessionState();

  /// Call once at startup. Restores the token AND the session profile.
  /// A token without a readable profile (e.g. saved by an older build)
  /// can't tell us the branch or user, so it is treated as signed out.
  /// Pair with a lightweight `/auth/me` call if you need server-side
  /// validation (expired/revoked tokens), not just presence.
  Future<void> restoreSession() async {
    final token = await _secureStorage.readAccessToken();
    final profile = SessionProfile.tryDecode(
      await _secureStorage.readSessionProfile(),
    );

    if (token == null || token.isEmpty || profile == null) {
      await _secureStorage.clearAuthTokens();
      await _secureStorage.clearSessionProfile();
      state = state.copyWith(status: AuthStatus.unauthenticated);
      return;
    }

    _apiClient.setAuthToken(token);
    state = AuthSessionState(
      status: AuthStatus.authenticated,
      accessToken: token,
      profile: profile,
    );
  }

  Future<void> onLoginSuccess({
    required String accessToken,
    String? refreshToken,
    required SessionProfile profile,
  }) async {
    await _secureStorage.saveAccessToken(accessToken);
    if (refreshToken != null) {
      await _secureStorage.saveRefreshToken(refreshToken);
    }
    await _secureStorage.saveSessionProfile(profile.encode());
    _apiClient.setAuthToken(accessToken);
    state = AuthSessionState(
      status: AuthStatus.authenticated,
      accessToken: accessToken,
      profile: profile,
    );
  }

  /// Persists a change to the signed-in user's profile (e.g. a future
  /// branch switch). No-op when signed out.
  Future<void> updateProfile(SessionProfile profile) async {
    if (!state.isLoggedIn) return;
    await _secureStorage.saveSessionProfile(profile.encode());
    state = state.copyWith(profile: profile);
  }

  Future<void> logout() async {
    await _secureStorage.clearAuthTokens();
    await _secureStorage.clearSessionProfile();
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

/// Branch of the signed-in user. Throws when there is no session so a
/// missing login fails loudly instead of silently using a wrong branch.
/// Read it with `ref.read(...)` in controllers, never `ref.watch`.
final sessionBranchIdProvider = Provider<int>((ref) {
  final profile = ref.watch(sessionProfileProvider);
  if (profile == null) {
    throw StateError('No session profile: the user is not signed in.');
  }
  return profile.branchId;
});