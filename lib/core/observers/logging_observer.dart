import 'package:flutter/widgets.dart';
import '../utils/app_logger.dart';

/// A [NavigatorObserver] that logs navigation events through [AppLogger].
/// Shows both the destination and the previous route for full context.
class LoggingObserver extends NavigatorObserver {
  String _describe(Route? route) {
    if (route == null) return 'none';
    return route.settings.name ?? route.runtimeType.toString();
  }

  @override
  void didPush(Route route, Route? previousRoute) {
    AppLogger.navigation('Pushed: ${_describe(route)}\nFrom  : ${_describe(previousRoute)}');
    super.didPush(route, previousRoute);
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    AppLogger.navigation('Popped: ${_describe(route)}\nBack to: ${_describe(previousRoute)}');
    super.didPop(route, previousRoute);
  }

  @override
  void didRemove(Route route, Route? previousRoute) {
    AppLogger.navigation('Removed: ${_describe(route)}\nContext: ${_describe(previousRoute)}');
    super.didRemove(route, previousRoute);
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    AppLogger.navigation('Replaced: ${_describe(oldRoute)} → ${_describe(newRoute)}');
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
  }

  @override
  void didStartUserGesture(Route route, Route? previousRoute) {
    AppLogger.navigation('Gesture started: ${_describe(route)}');
    super.didStartUserGesture(route, previousRoute);
  }
}

/*
Summary for go_router
context.push(path) -> Adds to top (Back button works).
context.replace(path) -> Swaps top screen (Back button goes to screen before the replaced one).
context.go(path) -> Clears stack and jumps to the new location.
 */