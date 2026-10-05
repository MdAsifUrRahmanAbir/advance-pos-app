class InvoicesModel {
  final String status;
  final String message;
  final int draw;
  final int recordsTotal;
  final int recordsFiltered;
  final int recordsShowing;
  final List<ResultDatum> resultData;

  InvoicesModel({
    required this.status,
    required this.message,
    required this.draw,
    required this.recordsTotal,
    required this.recordsFiltered,
    required this.recordsShowing,
    required this.resultData,
  });

  factory InvoicesModel.fromJson(Map<String, dynamic> json) => InvoicesModel(
    status: json["status"],
    message: json["message"],
    draw: json["draw"],
    recordsTotal: json["recordsTotal"],
    recordsFiltered: json["recordsFiltered"],
    recordsShowing: json["recordsShowing"],
    resultData: List<ResultDatum>.from(
      json["resultData"].map((x) => ResultDatum.fromJson(x)),
    ),
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
  final String salesDate;
  final String salesBillNo;
  final String totalQuantity;
  final String totalAmount;
  final String discountRate;
  final String discountAmount;
  final String taAfterDiscount;
  final String vatRate;
  final String vatAmount;
  final String deliveryCharge;
  final String totalPayableAmount;
  final String paidAmount;
  final List<Payment> paymentSystems;
  final List<Payment> paymentAccounts;
  final List<String> productNames;
  final String referenceNo;
  final String remarks;
  final String customerName;
  final String customerMobile;
  final String salesBy;

  ResultDatum({
    required this.sl,
    required this.salesDate,
    required this.salesBillNo,
    required this.totalQuantity,
    required this.totalAmount,
    required this.discountRate,
    required this.discountAmount,
    required this.taAfterDiscount,
    required this.vatRate,
    required this.vatAmount,
    required this.deliveryCharge,
    required this.totalPayableAmount,
    required this.paidAmount,
    required this.paymentSystems,
    required this.paymentAccounts,
    required this.productNames,
    required this.referenceNo,
    required this.remarks,
    required this.customerName,
    required this.customerMobile,
    required this.salesBy,
  });

  factory ResultDatum.fromJson(Map<String, dynamic> json) => ResultDatum(
    sl: json["sl"],
    salesDate: json["sales_date"],
    salesBillNo: json["sales_bill_no"],
    totalQuantity: json["total_quantity"],
    totalAmount: json["total_amount"],
    discountRate: json["discount_rate"],
    discountAmount: json["discount_amount"],
    taAfterDiscount: json["ta_after_discount"],
    vatRate: json["vat_rate"],
    vatAmount: json["vat_amount"],
    deliveryCharge: json["delivery_charge"],
    totalPayableAmount: json["total_payable_amount"],
    paidAmount: json["paid_amount"],
    paymentSystems: List<Payment>.from(
      json["payment_systems"].map((x) => Payment.fromJson(x)),
    ),
    paymentAccounts: List<Payment>.from(
      json["payment_accounts"].map((x) => Payment.fromJson(x)),
    ),
    productNames: List<String>.from(json["product_names"].map((x) => x)),
    referenceNo: json["reference_no"],
    remarks: json["remarks"],
    customerName: json["customer_name"],
    customerMobile: json["customer_mobile"],
    salesBy: json["sales_by"],
  );

  Map<String, dynamic> toJson() => {
    "sl": sl,
    "sales_date": salesDate,
    "sales_bill_no": salesBillNo,
    "total_quantity": totalQuantity,
    "total_amount": totalAmount,
    "discount_rate": discountRate,
    "discount_amount": discountAmount,
    "ta_after_discount": taAfterDiscount,
    "vat_rate": vatRate,
    "vat_amount": vatAmount,
    "delivery_charge": deliveryCharge,
    "total_payable_amount": totalPayableAmount,
    "paid_amount": paidAmount,
    "payment_systems": List<dynamic>.from(
      paymentSystems.map((x) => x.toJson()),
    ),
    "payment_accounts": List<dynamic>.from(
      paymentAccounts.map((x) => x.toJson()),
    ),
    "product_names": List<dynamic>.from(productNames.map((x) => x)),
    "reference_no": referenceNo,
    "remarks": remarks,
    "customer_name": customerName,
    "customer_mobile": customerMobile,
    "sales_by": salesBy,
  };
}

class Payment {
  final String id;
  final String name;

  Payment({required this.id, required this.name});

  factory Payment.fromJson(Map<String, dynamic> json) =>
      Payment(id: json["id"], name: json["name"] ?? "");

  Map<String, dynamic> toJson() => {"id": id, "name": name};
}
