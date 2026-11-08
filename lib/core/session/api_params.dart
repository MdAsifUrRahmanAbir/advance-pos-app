import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../storage/secure_storage_service.dart';

/// Fallback values for request params the login API does not (always)
/// return. Change them here only — never inline `1` / `0` in a
/// repository, controller or endpoint.
abstract final class ApiParamDefaults {
  /// `sales_type` for retail sales (sales list, details, delete, invoice,
  /// add, edit, discount, replacement).
  static const int salesType = 1;
  static const String clientApp = "pos";
  static const String systemToken = "2nMDQU2TodIJH9Y8oycSUKNDVcHh5KZKCbLAmamU";

  /// FLAG: login returns `emp_id: null` for users without an employee
  /// record; 0 is sent as `employee_id` until the backend defines this.
  static const int unknownEmployeeId = 0;
}

/// The values every API request carries: `branch_id`, `employee_id` and
/// `sales_type`. This file is the single source for them.
///
/// Where they are set:
/// - URL query params  -> [ApiEndpoints] (reads [ApiParams.current]).
/// - Request body      -> the repository method (reads [ApiParams.current]).
/// Controllers never pass them.
class ApiParams {
  final int branchId;
  final int employeeId;
  final int salesType;

  static ApiParams? _current;

  /// Cached params for code without a `ref` — `ApiEndpoints` and the
  /// repositories. Kept in sync by [ApiParamsController] (login, restore,
  /// logout). Throws [StateError] when nobody is signed in, so a request
  /// never goes out with a guessed branch.
  static ApiParams get current {
    final params = _current;
    if (params == null) {
      throw StateError('No API params cached: the user is not signed in.');
    }
    return params;
  }

  const ApiParams({
    required this.branchId,
    required this.employeeId,
    required this.salesType,
  });

  factory ApiParams.fromJson(Map<String, dynamic> json) => ApiParams(
    branchId: json['branchId'] as int,
    employeeId: json['employeeId'] as int,
    salesType: json['salesType'] as int,
  );

  Map<String, dynamic> toJson() => {
    'branchId': branchId,
    'employeeId': employeeId,
    'salesType': salesType,
  };

  String encode() => jsonEncode(toJson());

  /// Null when [raw] is missing or unreadable, so the caller can ask the
  /// user to sign in again.
  static ApiParams? tryDecode(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    try {
      return ApiParams.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }
}

/// Holds and caches [ApiParams]. Null while nobody is signed in.
///
/// - Login: [cacheFromLogin] with the login response values.
/// - App start: [restore] (called by the auth session restore).
/// - Logout: [clear].
class ApiParamsController extends Notifier<ApiParams?> {
  SecureStorageService get _storage => ref.read(secureStorageServiceProvider);

  @override
  ApiParams? build() => null;

  /// Saves the values from the login response (`user_config`) to secure
  /// storage and memory. Missing values fall back to [ApiParamDefaults].
  Future<void> cacheFromLogin({
    required int branchId,
    int? employeeId,
    int? salesType,
  }) async {
    final params = ApiParams(
      branchId: branchId,
      employeeId: employeeId ?? ApiParamDefaults.unknownEmployeeId,
      salesType: salesType ?? ApiParamDefaults.salesType,
    );
    await _storage.saveApiParams(params.encode());
    ApiParams._current = params;
    state = params;
  }

  /// Loads the cached values at startup. Returns null when nothing usable
  /// is cached (never signed in, logged out, or saved by an older build).
  Future<ApiParams?> restore() async {
    final params = ApiParams.tryDecode(await _storage.readApiParams());
    if (params == null) await _storage.clearApiParams();
    ApiParams._current = params;
    state = params;
    return params;
  }

  Future<void> clear() async {
    await _storage.clearApiParams();
    ApiParams._current = null;
    state = null;
  }
}

final apiParamsControllerProvider =
    NotifierProvider<ApiParamsController, ApiParams?>(ApiParamsController.new);

final apiParamsProvider = Provider<ApiParams>((ref) {
  final params = ref.watch(apiParamsControllerProvider);
  if (params == null) {
    throw StateError('No API params cached: the user is not signed in.');
  }
  return params;
});
