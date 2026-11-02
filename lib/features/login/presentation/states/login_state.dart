class LoginState {
  final bool rememberMe;
  final bool isSubmitting;
  final String? errorMessage;

  const LoginState({
    this.rememberMe = false,
    this.isSubmitting = false,
    this.errorMessage,
  });

  LoginState copyWith({
    bool? rememberMe,
    bool? isSubmitting,
    String? errorMessage,
    bool clearError = false,
  }) {
    return LoginState(
      rememberMe: rememberMe ?? this.rememberMe,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}