import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/session/auth_session_controller.dart';
import '../../../../core/session/auth_session_state.dart';
import '../../../../core/session/client_session_controller.dart';

// FLAG: no duration token exists; should become an AppDurations token.
const Duration splashMinDisplay = Duration(milliseconds: 2500);

/// Where the splash sends the user once startup restore is done.
enum SplashDestination {
  /// No verified company yet: Welcome (company code).
  welcome,

  /// Company verified, nobody signed in: Login.
  login,

  /// Company verified and signed in: main shell.
  home,
}

final splashControllerProvider =
NotifierProvider<SplashController, void>(SplashController.new);

class SplashController extends Notifier<void> {
  @override
  void build() {}

  /// Restores the company (API base URL) first, then the auth session,
  /// while enforcing a minimum splash time. Any failure falls back to the
  /// earliest step that still needs the user.
  Future<SplashDestination> bootstrap() async {
    final minDelay = Future<void>.delayed(splashMinDisplay);
    try {
      await ref.read(clientSessionControllerProvider.notifier).restore();
    } catch (_) {
      // Company could not be restored; ask for the code again.
    }
    final hasClient = ref.read(clientSessionControllerProvider) != null;

    if (hasClient) {
      try {
        await ref.read(authSessionControllerProvider.notifier).restoreSession();
      } catch (_) {
        // Session could not be restored; treat as signed out.
      }
    }
    await minDelay;
    if (!ref.mounted || !hasClient) return SplashDestination.welcome;

    final isAuthenticated = ref.read(authSessionControllerProvider).status ==
        AuthStatus.authenticated;
    return isAuthenticated ? SplashDestination.home : SplashDestination.login;
  }
}