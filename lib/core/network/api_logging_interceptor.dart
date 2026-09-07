import 'package:dio/dio.dart';
import '../utils/app_logger.dart';

/// Dio interceptor that logs every request (endpoint, query params,
/// headers, body) and every response/error (status, data, timing)
/// through [AppLogger]. Attach it in [ApiClient]'s interceptor list —
/// keep it first so timing wraps the auth interceptor too.
class ApiLoggingInterceptor extends Interceptor {
  final Map<RequestOptions, Stopwatch> _stopwatches = {};

  String _fullPath(RequestOptions options) => '${options.baseUrl}${options.path}';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _stopwatches[options] = Stopwatch()..start();
    AppLogger.apiRequest(
      method: options.method,
      endpoint: _fullPath(options),
      queryParams: options.queryParameters,
      headers: options.headers,
      body: options.data,
    );
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final stopwatch = _stopwatches.remove(response.requestOptions)?..stop();
    AppLogger.apiResponse(
      method: response.requestOptions.method,
      endpoint: _fullPath(response.requestOptions),
      statusCode: response.statusCode,
      data: response.data,
      duration: stopwatch?.elapsed,
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _stopwatches.remove(err.requestOptions);
    AppLogger.apiError(
      method: err.requestOptions.method,
      endpoint: _fullPath(err.requestOptions),
      statusCode: err.response?.statusCode,
      message: err.message,
      data: err.response?.data,
    );
    handler.next(err);
  }
}