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