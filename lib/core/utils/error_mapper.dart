import '../constants/app_strings.dart';
import '../network/api_exception.dart';
import 'app_logger.dart'; // TODO: confirm actual import path/class name of your existing AppLogger

/// Maps any caught error into a safe, user-facing message.
/// Always pass [stackTrace] from the catch block so parsing/unexpected
/// errors get logged with full trace (clickable in console) for devs,
/// while the UI only ever sees a safe, generic string.
String getErrorMessage(Object error, [StackTrace? stackTrace]) {
  if (error is ApiException) {
    // Already a clean, server/network-derived message — safe to show as-is.
    AppLogger.error('ApiException: $error', error, stackTrace);
    return error.message;
  }

  if (error is TypeError || error is FormatException) {
    // Model parsing failure — usually means backend response shape
    // doesn't match XModel.fromJson(). This is a contract bug, not a
    // user-facing error, so log it LOUD for devs.
    AppLogger.error('Model parsing failed: $error', error, stackTrace);
    return AppStrings.dataParsingError;
  }

  // Anything else unexpected.
  AppLogger.error('Unexpected error: $error', error, stackTrace);
  return AppStrings.unexpectedError;
}

/// Formats a dev-facing technical breakdown (error type / status code /
/// endpoint / message / first in-app stack frame) for a full-screen
/// "Technical Details" panel (e.g. `ErrorContent`/`TechnicalDetailsPanel`).
///
/// Kept separate from [getErrorMessage] on purpose: the user-facing
/// string from that function must always stay safe/generic, while this
/// one is intentionally verbose — only ever shown behind an explicit
/// "View technical details" tap, never rendered by default.
String buildTechnicalErrorDetails(
    Object error,
    StackTrace? stackTrace, {
      String? endpoint,
    }) {
  final buffer = StringBuffer();

  if (error is ApiException) {
    buffer.writeln('Error: ApiException');
    buffer.writeln('Status: ${error.statusCode ?? '-'}');
  } else {
    buffer.writeln('Error: ${error.runtimeType}');
  }

  if (endpoint != null) buffer.writeln('Endpoint: $endpoint');
  buffer.writeln('Message: $error');

  final frame = _firstAppFrame(stackTrace);
  if (frame != null) buffer.writeln('Stack: $frame');

  return buffer.toString().trim();
}

/// Picks the first stack-trace line that points into app code (not
/// Flutter/Dio internals) so the "Stack:" line in
/// [buildTechnicalErrorDetails] shows something actually useful — e.g.
/// `invoices_repository.dart:21:22` instead of a Dio internal frame.
String? _firstAppFrame(StackTrace? stackTrace) {
  if (stackTrace == null) return null;
  final lines = stackTrace.toString().split('\n');

  for (final line in lines) {
    if (line.contains('advance_pos_app')) {
      final match = RegExp(r'([\w_]+\.dart:\d+:\d+)').firstMatch(line);
      if (match != null) return match.group(1);
    }
  }
  return lines.isNotEmpty ? lines.first.trim() : null;
}