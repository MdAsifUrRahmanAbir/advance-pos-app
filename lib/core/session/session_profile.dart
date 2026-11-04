import 'dart:convert';

/// Who is signed in. Saved with the session and restored at startup.
/// Request params (branch, employee, sales type) live in `api_params.dart`,
/// not here. To add a field later, add it here and in [toJson]/[fromJson];
/// a new nullable field keeps old sessions valid.
class SessionProfile {
  final String sellerType;
  final String userName;

  /// From login `user_config` / `historys_id`. Nullable so sessions saved
  /// by older builds still decode.
  final int? userId;
  final int? companyId;
  final int? companyType;
  final int? historyId;

  /// From login `user_config.emp_id` / `employee_no`, shown on Profile.
  /// Null for users without an employee record and for older sessions.
  final int? employeeId;
  final String? employeeNo;

  const SessionProfile({
    required this.sellerType,
    required this.userName,
    this.userId,
    this.companyId,
    this.companyType,
    this.historyId,
    this.employeeId,
    this.employeeNo,
  });

  SessionProfile copyWith({
    String? sellerType,
    String? userName,
    int? userId,
    int? companyId,
    int? companyType,
    int? historyId,
    int? employeeId,
    String? employeeNo,
  }) {
    return SessionProfile(
      sellerType: sellerType ?? this.sellerType,
      userName: userName ?? this.userName,
      userId: userId ?? this.userId,
      companyId: companyId ?? this.companyId,
      companyType: companyType ?? this.companyType,
      historyId: historyId ?? this.historyId,
      employeeId: employeeId ?? this.employeeId,
      employeeNo: employeeNo ?? this.employeeNo,
    );
  }

  factory SessionProfile.fromJson(Map<String, dynamic> json) => SessionProfile(
    sellerType: json['sellerType'] as String,
    userName: json['userName'] as String,
    userId: json['userId'] as int?,
    companyId: json['companyId'] as int?,
    companyType: json['companyType'] as int?,
    historyId: json['historyId'] as int?,
    employeeId: json['employeeId'] as int?,
    employeeNo: json['employeeNo'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'sellerType': sellerType,
    'userName': userName,
    'userId': userId,
    'companyId': companyId,
    'companyType': companyType,
    'historyId': historyId,
    'employeeId': employeeId,
    'employeeNo': employeeNo,
  };

  String encode() => jsonEncode(toJson());

  /// Null when [raw] is missing or unreadable (corrupt or from an older
  /// build) so the caller can fall back to signing in again.
  static SessionProfile? tryDecode(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    try {
      return SessionProfile.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }
}
