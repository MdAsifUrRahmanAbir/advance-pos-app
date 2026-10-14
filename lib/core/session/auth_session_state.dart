import 'session_profile.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthSessionState {
  final AuthStatus status;
  final String? accessToken;

  /// Set whenever [status] is authenticated; null otherwise.
  final SessionProfile? profile;

  const AuthSessionState({
    this.status = AuthStatus.unknown,
    this.accessToken,
    this.profile,
  });

  bool get isLoggedIn => status == AuthStatus.authenticated;

  AuthSessionState copyWith({
    AuthStatus? status,
    String? accessToken,
    SessionProfile? profile,
  }) {
    return AuthSessionState(
      status: status ?? this.status,
      accessToken: accessToken ?? this.accessToken,
      profile: profile ?? this.profile,
    );
  }
}