enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthSessionState {
  final AuthStatus status;
  final String? accessToken;

  const AuthSessionState({this.status = AuthStatus.unknown, this.accessToken});

  AuthSessionState copyWith({AuthStatus? status, String? accessToken}) {
    return AuthSessionState(
      status: status ?? this.status,
      accessToken: accessToken ?? this.accessToken,
    );
  }
}