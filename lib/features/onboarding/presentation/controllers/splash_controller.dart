import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/session/auth_session_controller.dart';
import '../../../../core/session/auth_session_state.dart';

// FLAG: no duration token exists; should become an AppDurations token.
const Duration splashMinDisplay = Duration(milliseconds: 2500);

final splashControllerProvider =
NotifierProvider<SplashController, void>(SplashController.new);

class SplashController extends Notifier<void> {
  @override
  void build() {}

  /// Restores the session while enforcing a minimum splash time.
  /// Returns true when authenticated; any failure falls back to false.
  Future<bool> bootstrap() async {
    final minDelay = Future<void>.delayed(splashMinDisplay);
    try {
      await ref.read(authSessionControllerProvider.notifier).restoreSession();
    } catch (_) {
      // Session could not be restored; treat as signed out.
    }
    await minDelay;
    if (!ref.mounted) return false;
    return ref.read(authSessionControllerProvider).status ==
        AuthStatus.authenticated;
  }
}