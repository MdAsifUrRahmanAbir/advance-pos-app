
class PaymentSystemModel {
  final String status;
  final String message;
  final int recordsTotal;
  final int recordsShowing;
  final List<ResultDatum> resultData;

  PaymentSystemModel({
    required this.status,
    required this.message,
    required this.recordsTotal,
    required this.recordsShowing,
    required this.resultData,
  });

  factory PaymentSystemModel.fromJson(Map<String, dynamic> json) => PaymentSystemModel(
    status: json["status"],
    message: json["message"],
    recordsTotal: json["recordsTotal"],
    recordsShowing: json["recordsShowing"],
    resultData: List<ResultDatum>.from(json["resultData"].map((x) => ResultDatum.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "recordsTotal": recordsTotal,
    "recordsShowing": recordsShowing,
    "resultData": List<dynamic>.from(resultData.map((x) => x.toJson())),
  };
}

class ResultDatum {
  final int id;
  final String paymentSystemName;
  final String shortName;
  final String status;

  ResultDatum({
    required this.id,
    required this.paymentSystemName,
    required this.shortName,
    required this.status,
  });

  factory ResultDatum.fromJson(Map<String, dynamic> json) => ResultDatum(
    id: json["id"],
    paymentSystemName: json["payment_system_name"],
    shortName: json["short_name"],
    status: json["status"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "payment_system_name": paymentSystemName,
    "short_name": shortName,
    "status": status,
  };
}
