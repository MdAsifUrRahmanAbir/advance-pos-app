import 'dart:convert';

/// Who is signed in and where they work. Saved with the auth token and
/// restored at startup. To add a field later, add it here and in
/// [toJson]/[fromJson]; a new nullable field keeps old sessions valid.
class SessionProfile {
  final int branchId;
  final int employeeId;
  final String sellerType;
  final String userName;

  const SessionProfile({
    required this.branchId,
    required this.employeeId,
    required this.sellerType,
    required this.userName,
  });

  SessionProfile copyWith({
    int? branchId,
    int? employeeId,
    String? sellerType,
    String? userName,
  }) {
    return SessionProfile(
      branchId: branchId ?? this.branchId,
      employeeId: employeeId ?? this.employeeId,
      sellerType: sellerType ?? this.sellerType,
      userName: userName ?? this.userName,
    );
  }

  factory SessionProfile.fromJson(Map<String, dynamic> json) => SessionProfile(
    branchId: json['branchId'] as int,
    employeeId: json['employeeId'] as int,
    sellerType: json['sellerType'] as String,
    userName: json['userName'] as String,
  );

  Map<String, dynamic> toJson() => {
    'branchId': branchId,
    'employeeId': employeeId,
    'sellerType': sellerType,
    'userName': userName,
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