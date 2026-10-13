class CommonSuccessModel {
  final String status;
  final String message;

  CommonSuccessModel({required this.status, required this.message});

  factory CommonSuccessModel.fromJson(Map<String, dynamic> json) =>
      CommonSuccessModel(
        status: json["status"] ?? json["alert_type"],
        message: json["message"] == null
            ? json["data"]
            : json["message"].toString().isNotEmpty
            ? json["message"]
            : json["data"],
      );

  Map<String, dynamic> toJson() => {"status": status, "message": message};
}
