class CustomersModel {
  final String status;
  final String message;
  final int draw;
  final int recordsTotal;
  final int recordsFiltered;
  final int recordsShowing;
  final List<ResultDatum> resultData;

  CustomersModel({
    required this.status,
    required this.message,
    required this.draw,
    required this.recordsTotal,
    required this.recordsFiltered,
    required this.recordsShowing,
    required this.resultData,
  });

  factory CustomersModel.fromJson(Map<String, dynamic> json) => CustomersModel(
    status: json["status"],
    message: json["message"],
    draw: json["draw"],
    recordsTotal: json["recordsTotal"],
    recordsFiltered: json["recordsFiltered"],
    recordsShowing: json["recordsShowing"],
    resultData: List<ResultDatum>.from(json["resultData"].map((x) => ResultDatum.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "draw": draw,
    "recordsTotal": recordsTotal,
    "recordsFiltered": recordsFiltered,
    "recordsShowing": recordsShowing,
    "resultData": List<dynamic>.from(resultData.map((x) => x.toJson())),
  };
}

class ResultDatum {
  final int sl;
  final String customerNo;
  final String customerName;
  final int customerType;
  final dynamic isPurchase;
  final String customerMobile;
  final String customerEmail;
  final String branchName;

  ResultDatum({
    required this.sl,
    required this.customerNo,
    required this.customerName,
    required this.customerType,
    required this.isPurchase,
    required this.customerMobile,
    required this.customerEmail,
    required this.branchName,
  });

  factory ResultDatum.fromJson(Map<String, dynamic> json) => ResultDatum(
    sl: json["sl"],
    customerNo: json["customer_no"],
    customerName: json["customer_name"],
    customerType: json["customer_type"],
    isPurchase: json["is_purchase"],
    customerMobile: json["customer_mobile"],
    customerEmail: json["customer_email"] ?? "",
    branchName: json["branch_name"],
  );

  Map<String, dynamic> toJson() => {
    "sl": sl,
    "customer_no": customerNo,
    "customer_name": customerName,
    "customer_type": customerType,
    "is_purchase": isPurchase,
    "customer_mobile": customerMobile,
    "customer_email": customerEmail,
    "branch_name": branchName,
  };
}