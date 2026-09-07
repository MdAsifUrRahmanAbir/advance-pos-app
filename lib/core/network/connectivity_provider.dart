import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../network/connectivity_service.dart';

final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  final service = ConnectivityService()..start();
  ref.onDispose(service.dispose);
  return service;
});

/// Synchronous connectivity flag mirrored from [ConnectivityService]'s
/// stream. Deliberately a plain `bool`, not an `AsyncValue<bool>` — the
/// router's `redirect` callback needs to read this synchronously on every
/// navigation, and there's no meaningful "loading" state to represent
/// there (see initial value note below).
class ConnectivityStatusController extends Notifier<bool> {
  StreamSubscription<bool>? _subscription;

  @override
  bool build() {
    final service = ref.watch(connectivityServiceProvider);

    _subscription?.cancel();
    _subscription = service.onStatusChange.listen((isConnected) {
      state = isConnected;
    });
    ref.onDispose(() => _subscription?.cancel());

    // Optimistic default: assume connected until the first real check
    // resolves, so the router doesn't bounce to no-internet on a cold
    // start before checkNow() has had a chance to run. SplashScreen's
    // own checkNow() call resolves this within milliseconds; the
    // stream listener above then keeps this state accurate afterward.
    return true;
  }
}

final connectivityStatusProvider =
NotifierProvider<ConnectivityStatusController, bool>(ConnectivityStatusController.new);

/// User explicitly chose "Work Offline" on [NoInternetScreen]. While true,
/// router redirects to the no-internet screen are suppressed even if the
/// device is genuinely offline. Cleared automatically once real
/// connectivity returns (see redirect logic in app_router.dart).
class OfflineModeController extends Notifier<bool> {
  @override
  bool build() => false;

  void enable() => state = true;
  void disable() => state = false;
}

final offlineModeProvider = NotifierProvider<OfflineModeController, bool>(OfflineModeController.new);

/// Adapts a Riverpod-exposed stream into a [Listenable] so [GoRouter]'s
/// `refreshListenable` re-evaluates `redirect` on every connectivity
/// change — including while the user is sitting on a screen and doesn't
/// trigger navigation themselves.
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}