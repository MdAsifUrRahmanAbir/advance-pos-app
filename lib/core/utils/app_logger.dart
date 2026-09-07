import 'package:flutter/foundation.dart';

class AppLogger {
  AppLogger._();

  static const String _line =
      '────────────────────────────────────────────────────────────';

  static void _box(
      String emoji,
      String title,
      String body,
      ) {
    if (!kDebugMode) return;

    debugPrint(
      '\n'
          '$emoji  $title\n'
          '$_line\n'
          '$body\n'
          '$_line',
    );
  }

  // ── Navigation ──────────────────────────────────────────────

  static void navigation(String message) {
    _box(
      '🧭',
      'NAVIGATION',
      message,
    );
  }

  // ── Riverpod ────────────────────────────────────────────────

  static void controllerOpened(String name) {
    _box(
      '🟢',
      'CONTROLLER OPENED  •  $name',
      'Initialized and now active.',
    );
  }

  static void controllerUpdated(
      String name, {
        String? previous,
        String? next,
      }) {
    final lines = <String>[
      if (previous != null) 'Previous : $previous',
      if (next != null) 'Next     : $next',
    ];

    _box(
      '🔄',
      'CONTROLLER UPDATED  •  $name',
      lines.isEmpty ? 'State changed.' : lines.join('\n'),
    );
  }

  static void controllerClosed(String name) {
    _box(
      '🔴',
      'CONTROLLER CLOSED  •  $name',
      'Disposed and removed from the container.',
    );
  }

  static void controllerFailed(
      String name,
      Object error,
      ) {
    _box(
      '💥',
      'CONTROLLER FAILED  •  $name',
      'Error: $error',
    );
  }

  // ── API ─────────────────────────────────────────────────────

  static void apiRequest({
    required String method,
    required String endpoint,
    Map<String, dynamic>? queryParams,
    Map<String, dynamic>? headers,
    dynamic body,
  }) {
    final lines = <String>[
      'Endpoint : $endpoint',
      if (queryParams != null && queryParams.isNotEmpty)
        'Query    : $queryParams',
      if (headers != null && headers.isNotEmpty)
        'Headers  : $headers',
      if (body != null)
        'Body     : $body',
    ];

    _box(
      '📤',
      'API REQUEST  •  $method',
      lines.join('\n'),
    );
  }

  static void apiResponse({
    required String method,
    required String endpoint,
    required int? statusCode,
    dynamic data,
    Duration? duration,
  }) {
    final lines = <String>[
      'Endpoint : $endpoint',
      'Status   : $statusCode',
      if (duration != null)
        'Time     : ${duration.inMilliseconds}ms',
      'Data     : $data',
    ];

    _box(
      '📥',
      'API RESPONSE  •  $method  [$statusCode]',
      lines.join('\n'),
    );
  }

  static void apiError({
    required String method,
    required String endpoint,
    int? statusCode,
    dynamic message,
    dynamic data,
  }) {
    final lines = <String>[
      'Endpoint : $endpoint',
      if (statusCode != null)
        'Status   : $statusCode',
      'Message  : $message',
      if (data != null)
        'Data     : $data',
    ];

    _box(
      '🚨',
      'API ERROR  •  $method',
      lines.join('\n'),
    );
  }
}