class CommonSuccessModel {
  final String status;
  final String message;

  CommonSuccessModel({
    required this.status,
    required this.message,
  });

  factory CommonSuccessModel.fromJson(Map<String, dynamic> json) => CommonSuccessModel(
    status: json["status"],
    message: json["message"],
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
  };
}
