import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/api_endpoints.dart';
import 'api_exception.dart';
import 'api_logging_interceptor.dart';
import 'connectivity_provider.dart';

final apiClientProvider = Provider<ApiClient>((ref) {
  final connectivityService = ref.watch(connectivityServiceProvider);
  return ApiClient(isConnected: () => connectivityService.isConnected);
});

class ApiClient {
  late final Dio _dio;
  String? _authToken;

  /// Synchronous connectivity check, read fresh on every request. Defaults
  /// to always-true so ApiClient can still be constructed directly (tests,
  /// tools) without wiring up connectivity — real app usage always goes
  /// through [apiClientProvider], which injects the real check.
  final bool Function() _isConnected;

  ApiClient({bool Function()? isConnected}) : _isConnected = isConnected ?? (() => true) {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
        headers: {
          // 'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Added first, deliberately: blocks offline requests before they reach
    // the logging interceptor (so nothing gets logged as "sent" when it
    // never left the device) and before the auth interceptor (so no token
    // work happens on a request that's about to be rejected anyway).
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        if (!_isConnected()) {
          handler.reject(
            DioException(
              requestOptions: options,
              type: DioExceptionType.connectionError,
              error: 'No internet connection — request blocked before dispatch.',
            ),
          );
          return;
        }
        return handler.next(options);
      },
    ));

    _dio.interceptors.add(ApiLoggingInterceptor());

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        if (_authToken != null && _authToken!.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $_authToken';
        }
        return handler.next(options);
      },
      onError: (DioException e, handler) {
        handler.next(e);
      },
    ));
  }

  void setAuthToken(String? token) {
    _authToken = token;
  }

  Future<Response> get(
      String path, {
        Map<String, dynamic>? queryParameters,
        Options? options,
        CancelToken? cancelToken,
      }) async {
    try {
      return await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<Response> post(
      String path, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        Options? options,
        CancelToken? cancelToken,
      }) async {
    try {
      return await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<Response> put(
      String path, {
        dynamic data,
        Options? options,
        CancelToken? cancelToken,
      }) async {
    try {
      return await _dio.put(
        path,
        data: data,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<Response> patch(
      String path, {
        dynamic data,
        Options? options,
        CancelToken? cancelToken,
      }) async {
    try {
      return await _dio.patch(
        path,
        data: data,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<Response> delete(
      String path, {
        dynamic data,
        Options? options,
        CancelToken? cancelToken,
      }) async {
    try {
      return await _dio.delete(
        path,
        data: data,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Upload a single file (photo, document, etc.)
  Future<Response> uploadFile(
      String path,
      String filePath, {
        String fileKey = 'file',
        Map<String, dynamic>? extraData,
        ProgressCallback? onSendProgress,
        CancelToken? cancelToken,
      }) async {
    try {
      String fileName = filePath.split('/').last;
      FormData formData = FormData.fromMap({
        fileKey: await MultipartFile.fromFile(filePath, filename: fileName),
        ...?extraData,
      });
      return await _dio.post(
        path,
        data: formData,
        onSendProgress: onSendProgress,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Upload multiple files (photos, documents, etc.) in a single request
  Future<Response> uploadFiles(
      String path,
      List<String> filePaths, {
        String fileKey = 'files[]',
        Map<String, dynamic>? extraData,
        ProgressCallback? onSendProgress,
        CancelToken? cancelToken,
      }) async {
    try {
      List<MultipartFile> multipartFiles = [];
      for (String filePath in filePaths) {
        String fileName = filePath.split('/').last;
        multipartFiles.add(
          await MultipartFile.fromFile(filePath, filename: fileName),
        );
      }

      Map<String, dynamic> mapData = {
        fileKey: multipartFiles,
        ...?extraData,
      };

      FormData formData = FormData.fromMap(mapData);

      return await _dio.post(
        path,
        data: formData,
        onSendProgress: onSendProgress,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

}