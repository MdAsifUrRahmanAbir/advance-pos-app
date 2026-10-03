class SalesSuccessModel {
  final String message;
  final String alertType;
  final String salesBillNo;

  SalesSuccessModel({
    required this.message,
    required this.alertType,
    required this.salesBillNo,
  });

  factory SalesSuccessModel.fromJson(Map<String, dynamic> json) => SalesSuccessModel(
    message: json["message"],
    alertType: json["alert-type"],
    salesBillNo: json["sales_bill_no"],
  );

  Map<String, dynamic> toJson() => {
    "message": message,
    "alert-type": alertType,
    "sales_bill_no": salesBillNo,
  };
}
