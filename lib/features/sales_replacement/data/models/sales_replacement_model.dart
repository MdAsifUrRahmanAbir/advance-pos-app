
class SalesReplacementModel {
  final String status;
  final String message;
  final int draw;
  final int recordsTotal;
  final int recordsFiltered;
  final int recordsShowing;
  final List<ResultDatum> resultData;

  SalesReplacementModel({
    required this.status,
    required this.message,
    required this.draw,
    required this.recordsTotal,
    required this.recordsFiltered,
    required this.recordsShowing,
    required this.resultData,
  });

  factory SalesReplacementModel.fromJson(Map<String, dynamic> json) => SalesReplacementModel(
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
  final String returnDate;
  final String returnBillNo;
  final String salesBillNo;
  final String totalReturnQuantity;
  final String totalReturnAmount;
  final String payableReturnAmount;
  final String returnDisAmount;
  final List<String> productNames;
  final String customerName;
  final String returnBy;
  final int isActive;

  ResultDatum({
    required this.sl,
    required this.returnDate,
    required this.returnBillNo,
    required this.salesBillNo,
    required this.totalReturnQuantity,
    required this.totalReturnAmount,
    required this.payableReturnAmount,
    required this.returnDisAmount,
    required this.productNames,
    required this.customerName,
    required this.returnBy,
    required this.isActive,
  });

  factory ResultDatum.fromJson(Map<String, dynamic> json) => ResultDatum(
    sl: json["sl"],
    returnDate: json["return_date"],
    returnBillNo: json["return_bill_no"],
    salesBillNo: json["sales_bill_no"],
    totalReturnQuantity: json["total_return_quantity"],
    totalReturnAmount: json["total_return_amount"],
    payableReturnAmount: json["payable_return_amount"],
    returnDisAmount: json["return_dis_amount"],
    productNames: List<String>.from(json["product_names"].map((x) => x)),
    customerName: json["customer_name"],
    returnBy: json["return_by"],
    isActive: json["is_active"],
  );

  Map<String, dynamic> toJson() => {
    "sl": sl,
    "return_date": returnDate,
    "return_bill_no": returnBillNo,
    "sales_bill_no": salesBillNo,
    "total_return_quantity": totalReturnQuantity,
    "total_return_amount": totalReturnAmount,
    "payable_return_amount": payableReturnAmount,
    "return_dis_amount": returnDisAmount,
    "product_names": List<dynamic>.from(productNames.map((x) => x)),
    "customer_name": customerName,
    "return_by": returnBy,
    "is_active": isActive,
  };
}
