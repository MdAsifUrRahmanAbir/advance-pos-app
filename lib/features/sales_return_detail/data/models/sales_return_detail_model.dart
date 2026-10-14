/// GET /sales_return/view/{id}. Hand-written in generated style but
/// tolerant: every field accepts a number or a string, nullable fields
/// get defaults.
// TODO: replace with the generated model (add_api_feature.py) if preferred.
String _str(dynamic v) => v?.toString() ?? '';

class SalesReturnDetailModel {
  final String status;
  final String message;
  final SalesReturnDetailData resultData;

  SalesReturnDetailModel({
    required this.status,
    required this.message,
    required this.resultData,
  });

  factory SalesReturnDetailModel.fromJson(Map<String, dynamic> json) =>
      SalesReturnDetailModel(
        status: _str(json["status"]),
        message: _str(json["message"]),
        resultData: SalesReturnDetailData.fromJson(json["resultData"]),
      );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "resultData": resultData.toJson(),
  };
}

class SalesReturnDetailData {
  final SalesReturnInfo returnInfo; // JSON key "return"
  final SalesReturnPayment payment;
  final String customerName;
  final String returnBy;
  final List<SalesReturnLine> returnDetails;

  SalesReturnDetailData({
    required this.returnInfo,
    required this.payment,
    required this.customerName,
    required this.returnBy,
    required this.returnDetails,
  });

  factory SalesReturnDetailData.fromJson(Map<String, dynamic> json) =>
      SalesReturnDetailData(
        returnInfo: SalesReturnInfo.fromJson(json["return"]),
        payment: SalesReturnPayment.fromJson(json["payment"] ?? const {}),
        customerName: _str(json["customer_name"]),
        returnBy: _str(json["return_by"]),
        returnDetails: [
          for (final x in (json["returnDetails"] as List? ?? const []))
            SalesReturnLine.fromJson(x),
        ],
      );

  Map<String, dynamic> toJson() => {
    "return": returnInfo.toJson(),
    "payment": payment.toJson(),
    "customer_name": customerName,
    "return_by": returnBy,
    "returnDetails": returnDetails.map((x) => x.toJson()).toList(),
  };
}

class SalesReturnInfo {
  final String returnBillNo;
  final String salesBillNo;
  final String returnDate;
  final String totalReturnQuantity;
  final String totalReturnAmount;
  final String returnDisAmount;
  final String? salesDisRate;
  final String taAfterDiscount;
  final String totalCostAmount;
  final String payableReturnAmount;
  final String remarks;

  SalesReturnInfo({
    required this.returnBillNo,
    required this.salesBillNo,
    required this.returnDate,
    required this.totalReturnQuantity,
    required this.totalReturnAmount,
    required this.returnDisAmount,
    required this.salesDisRate,
    required this.taAfterDiscount,
    required this.totalCostAmount,
    required this.payableReturnAmount,
    required this.remarks,
  });

  factory SalesReturnInfo.fromJson(Map<String, dynamic> json) =>
      SalesReturnInfo(
        returnBillNo: _str(json["return_bill_no"]),
        salesBillNo: _str(json["sales_bill_no"]),
        returnDate: _str(json["return_date"]),
        totalReturnQuantity: _str(json["total_return_quantity"]),
        totalReturnAmount: _str(json["total_return_amount"]),
        returnDisAmount: _str(json["return_dis_amount"]),
        salesDisRate: json["sales_dis_rate"]?.toString(),
        taAfterDiscount: _str(json["ta_after_discount"]),
        totalCostAmount: _str(json["total_cost_amount"]),
        payableReturnAmount: _str(json["payable_return_amount"]),
        remarks: _str(json["remarks"]),
      );

  Map<String, dynamic> toJson() => {
    "return_bill_no": returnBillNo,
    "sales_bill_no": salesBillNo,
    "return_date": returnDate,
    "total_return_quantity": totalReturnQuantity,
    "total_return_amount": totalReturnAmount,
    "return_dis_amount": returnDisAmount,
    "sales_dis_rate": salesDisRate,
    "ta_after_discount": taAfterDiscount,
    "total_cost_amount": totalCostAmount,
    "payable_return_amount": payableReturnAmount,
    "remarks": remarks,
  };
}

class SalesReturnPayment {
  final List<SalesReturnNamedItem> paymentSystems;
  final List<SalesReturnNamedItem> paymentAccounts;

  SalesReturnPayment({
    required this.paymentSystems,
    required this.paymentAccounts,
  });

  factory SalesReturnPayment.fromJson(Map<String, dynamic> json) =>
      SalesReturnPayment(
        paymentSystems: [
          for (final x in (json["payment_systems"] as List? ?? const []))
            SalesReturnNamedItem.fromJson(x),
        ],
        paymentAccounts: [
          for (final x in (json["payment_accounts"] as List? ?? const []))
            SalesReturnNamedItem.fromJson(x),
        ],
      );

  Map<String, dynamic> toJson() => {
    "payment_systems": paymentSystems.map((x) => x.toJson()).toList(),
    "payment_accounts": paymentAccounts.map((x) => x.toJson()).toList(),
  };
}

class SalesReturnNamedItem {
  final String id;
  final String name;

  SalesReturnNamedItem({required this.id, required this.name});

  factory SalesReturnNamedItem.fromJson(Map<String, dynamic> json) =>
      SalesReturnNamedItem(id: _str(json["id"]), name: _str(json["name"]));

  Map<String, dynamic> toJson() => {"id": id, "name": name};
}

class SalesReturnLine {
  final int productId;
  final String productName;
  final String productBarcode;
  final String costPrice;
  final String salesPrice;
  final String quantity;
  final String disRate;
  final String disAmount;
  final String totalAmount;
  final num netRate;

  SalesReturnLine({
    required this.productId,
    required this.productName,
    required this.productBarcode,
    required this.costPrice,
    required this.salesPrice,
    required this.quantity,
    required this.disRate,
    required this.disAmount,
    required this.totalAmount,
    required this.netRate,
  });

  factory SalesReturnLine.fromJson(Map<String, dynamic> json) =>
      SalesReturnLine(
        productId: (json["product_id"] as num?)?.toInt() ?? 0,
        productName: _str(json["product_name"]),
        productBarcode: _str(json["product_barcode"]),
        costPrice: _str(json["cost_price"]),
        salesPrice: _str(json["sales_price"]),
        quantity: _str(json["quantity"]),
        disRate: _str(json["dis_rate"]),
        disAmount: _str(json["dis_amount"]),
        totalAmount: _str(json["total_amount"]),
        netRate: (json["net_rate"] as num?) ?? 0,
      );

  Map<String, dynamic> toJson() => {
    "product_id": productId,
    "product_name": productName,
    "product_barcode": productBarcode,
    "cost_price": costPrice,
    "sales_price": salesPrice,
    "quantity": quantity,
    "dis_rate": disRate,
    "dis_amount": disAmount,
    "total_amount": totalAmount,
    "net_rate": netRate,
  };
}