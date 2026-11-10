class ClientInfoModel {
  final String status;
  final String message;
  final ClientInfoData? data;

  ClientInfoModel({
    required this.status,
    required this.message,
    required this.data,
  });

  factory ClientInfoModel.fromJson(Map<String, dynamic> json) => ClientInfoModel(
    status: json["status"]?.toString() ?? '',
    message: json["message"]?.toString() ?? '',
    data: json["data"] is Map<String, dynamic>
        ? ClientInfoData.fromJson(json["data"])
        : null,
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": data?.toJson(),
  };
}

class ClientInfoData {
  final String name;
  final String compCode;
  final String logo;
  final String product;
  final String app;
  final String baseUrl;
  final String clientToken;

  ClientInfoData({
    required this.name,
    required this.compCode,
    required this.logo,
    required this.product,
    required this.app,
    required this.baseUrl,
    required this.clientToken,
  });

  factory ClientInfoData.fromJson(Map<String, dynamic> json) => ClientInfoData(
    name: json["name"]?.toString() ?? '',
    compCode: json["comp_code"]?.toString() ?? '',
    logo: json["logo"]?.toString() ?? '',
    product: json["product"]?.toString() ?? '',
    app: json["app"]?.toString() ?? '',
    baseUrl: json["base_url"]?.toString() ?? '',
    clientToken: json["client_token"]?.toString() ?? '',
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "comp_code": compCode,
    "logo": logo,
    "product": product,
    "app": app,
    "base_url": baseUrl,
  };
}