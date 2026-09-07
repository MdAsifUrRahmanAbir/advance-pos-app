import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/app_logger.dart';

/// Logs Riverpod provider lifecycle events.
final class RiverpodLoggingObserver extends ProviderObserver {
  String _nameOf(ProviderObserverContext context) {
    return context.provider.name ??
        context.provider.runtimeType.toString();
  }

  @override
  void didAddProvider(
      ProviderObserverContext context,
      Object? value,
      ) {
    AppLogger.controllerOpened(_nameOf(context));
  }

  @override
  void didUpdateProvider(
      ProviderObserverContext context,
      Object? previousValue,
      Object? newValue,
      ) {
    AppLogger.controllerUpdated(
      _nameOf(context),
      previous: previousValue?.toString(),
      next: newValue?.toString(),
    );
  }

  @override
  void didDisposeProvider(
      ProviderObserverContext context,
      ) {
    AppLogger.controllerClosed(_nameOf(context));
  }

  @override
  void providerDidFail(
      ProviderObserverContext context,
      Object error,
      StackTrace stackTrace,
      ) {
    AppLogger.controllerFailed(
      _nameOf(context),
      error,
    );
  }
}