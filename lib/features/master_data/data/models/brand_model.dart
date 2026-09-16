class BrandModel {
  final String status;
  final String message;
  final int recordsTotal;
  final int recordsShowing;
  final List<BrandItem> resultData;

  BrandModel({
    required this.status,
    required this.message,
    required this.recordsTotal,
    required this.recordsShowing,
    required this.resultData,
  });

  factory BrandModel.fromJson(Map<String, dynamic> json) => BrandModel(
    status: json["status"],
    message: json["message"],
    recordsTotal: json["recordsTotal"],
    recordsShowing: json["recordsShowing"],
    resultData: List<BrandItem>.from(json["resultData"].map((x) => BrandItem.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "recordsTotal": recordsTotal,
    "recordsShowing": recordsShowing,
    "resultData": List<dynamic>.from(resultData.map((x) => x.toJson())),
  };
}

class BrandItem {
  final int sl;
  final int id;
  final String modelName;
  final String modelCode;

  BrandItem({
    required this.sl,
    required this.id,
    required this.modelName,
    required this.modelCode,
  });

  factory BrandItem.fromJson(Map<String, dynamic> json) => BrandItem(
    sl: json["sl"],
    id: json["id"],
    modelName: json["model_name"],
    modelCode: json["model_code"],
  );

  Map<String, dynamic> toJson() => {
    "sl": sl,
    "id": id,
    "model_name": modelName,
    "model_code": modelCode,
  };
}