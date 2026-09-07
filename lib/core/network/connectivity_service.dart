import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';

/// Wraps [Connectivity] (interface-level: wifi/mobile/none) with an actual
/// internet-reachability probe, since being associated with a WiFi router
/// doesn't guarantee that router has internet access.
///
/// Emits `true`/`false` on [onStatusChange] whenever real internet access
/// is gained or lost, and exposes [checkNow] for a manual one-off check
/// (wired to the "Check Connection" button on [NoInternetScreen]).
///
/// Uses a plain [Dio] HEAD-request probe rather than `dart:io`'s
/// `InternetAddress.lookup` so this also works on Flutter Web.
class ConnectivityService {
  ConnectivityService({Connectivity? connectivity, Dio? probeClient})
      : _connectivity = connectivity ?? Connectivity(),
        _probeClient = probeClient ??
            Dio(BaseOptions(
              connectTimeout: const Duration(seconds: 4),
              receiveTimeout: const Duration(seconds: 4),
            ));

  final Connectivity _connectivity;
  final Dio _probeClient;
  final StreamController<bool> _statusController = StreamController<bool>.broadcast();
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  bool? _lastStatus;

  /// Lightweight endpoints used for the reachability probe. More than one
  /// so a single host outage doesn't falsely report "offline".
  static const List<String> _probeUrls = [
    'https://www.google.com/generate_204',
    'https://one.one.one.one',
  ];

  Stream<bool> get onStatusChange => _statusController.stream;

  void start() {
    _subscription ??= _connectivity.onConnectivityChanged.listen((_) => checkNow());
    checkNow();
  }

  void dispose() {
    _subscription?.cancel();
    _statusController.close();
  }

  /// Runs an immediate reachability check and emits the result if it
  /// changed since the last check. Returns the fresh status.
  bool get isConnected => _lastStatus ?? true;

  Future<bool> checkNow() async {
    final hasInternet = await _hasActualInternet();
    if (hasInternet != _lastStatus) {
      _lastStatus = hasInternet; // set first
      if (!_statusController.isClosed) _statusController.add(hasInternet); // then notify
    }
    return hasInternet;
  }

  Future<bool> _hasActualInternet() async {
    final interfaceResults = await _connectivity.checkConnectivity();
    if (interfaceResults.every((r) => r == ConnectivityResult.none)) {
      return false;
    }

    for (final url in _probeUrls) {
      try {
        final response = await _probeClient.head(url);
        if (response.statusCode != null && response.statusCode! < 500) {
          return true;
        }
      } catch (_) {
        // try next host
      }
    }
    return false;
  }
}