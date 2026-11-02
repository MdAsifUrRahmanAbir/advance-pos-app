class LoginModel {
  final bool success;
  final String? message;
  final LoginData? data;

  LoginModel({required this.success, this.message, this.data});

  factory LoginModel.fromJson(Map<String, dynamic> json) => LoginModel(
    success: json["success"] ?? false,
    message: json["message"]?.toString(),
    data: json["data"] == null ? null : LoginData.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "data": data?.toJson(),
  };
}

class LoginData {
  final UserConfig userConfig;
  final int? historysId;
  final String? lastLoginIp;
  final String? lastLoginTime;

  LoginData({
    required this.userConfig,
    this.historysId,
    this.lastLoginIp,
    this.lastLoginTime,
  });

  factory LoginData.fromJson(Map<String, dynamic> json) => LoginData(
    userConfig: UserConfig.fromJson(json["user_config"]),
    historysId: json["historys_id"],
    lastLoginIp: json["last_login_ip"],
    lastLoginTime: json["last_login_time"],
  );

  Map<String, dynamic> toJson() => {
    "user_config": userConfig.toJson(),
    "historys_id": historysId,
    "last_login_ip": lastLoginIp,
    "last_login_time": lastLoginTime,
  };
}

class UserConfig {
  final int userId;
  final String fullName;
  final int companyId;
  final int companyType;
  final int branchId;
  final String? employeeNo;
  final int? empId;

  UserConfig({
    required this.userId,
    required this.fullName,
    required this.companyId,
    required this.companyType,
    required this.branchId,
    this.employeeNo,
    this.empId,
  });

  factory UserConfig.fromJson(Map<String, dynamic> json) => UserConfig(
    userId: json["user_id"],
    fullName: json["full_name"] ?? "",
    companyId: json["company_id"],
    companyType: json["company_type"],
    branchId: json["branch_id"],
    employeeNo: json["employee_no"]?.toString(),
    empId: json["emp_id"],
  );

  Map<String, dynamic> toJson() => {
    "user_id": userId,
    "full_name": fullName,
    "company_id": companyId,
    "company_type": companyType,
    "branch_id": branchId,
    "employee_no": employeeNo,
    "emp_id": empId,
  };
}