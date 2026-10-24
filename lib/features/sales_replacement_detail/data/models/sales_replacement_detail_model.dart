class SalesReplacementDetailModel {
  final String status;
  final String message;
  final ResultData resultData;

  SalesReplacementDetailModel({
    required this.status,
    required this.message,
    required this.resultData,
  });

  factory SalesReplacementDetailModel.fromJson(Map<String, dynamic> json) => SalesReplacementDetailModel(
    status: json["status"],
    message: json["message"],
    resultData: ResultData.fromJson(json["resultData"]),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "resultData": resultData.toJson(),
  };
}

class ResultData {
  final Return resultDataReturn;
  final String returnBy;
  final String employeeId;
  final List<ReturnDetail> returnDetails;
  final ReplacementSale replacementSale;
  final String customerName;
  final String customerMobile;
  final dynamic customerNo;
  final List<ReplacementDetail> replacementDetails;

  ResultData({
    required this.resultDataReturn,
    required this.returnBy,
    required this.employeeId,
    required this.returnDetails,
    required this.replacementSale,
    required this.customerName,
    required this.customerMobile,
    required this.customerNo,
    required this.replacementDetails,
  });

  factory ResultData.fromJson(Map<String, dynamic> json) => ResultData(
    resultDataReturn: Return.fromJson(json["return"]),
    returnBy: json["return_by"],
    employeeId: json["employee_id"],
    returnDetails: List<ReturnDetail>.from(json["returnDetails"].map((x) => ReturnDetail.fromJson(x))),
    replacementSale: ReplacementSale.fromJson(json["replacement_sale"]),
    customerName: json["customer_name"],
    customerMobile: json["customer_mobile"],
    customerNo: json["customer_no"],
    replacementDetails: List<ReplacementDetail>.from(json["replacementDetails"].map((x) => ReplacementDetail.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "return": resultDataReturn.toJson(),
    "return_by": returnBy,
    "employee_id": employeeId,
    "returnDetails": List<dynamic>.from(returnDetails.map((x) => x.toJson())),
    "replacement_sale": replacementSale.toJson(),
    "customer_name": customerName,
    "customer_mobile": customerMobile,
    "customer_no": customerNo,
    "replacementDetails": List<dynamic>.from(replacementDetails.map((x) => x.toJson())),
  };
}

class ReplacementDetail {
  final int productId;
  final String productName;
  final String productBarcode;
  final String unitPrice;
  final String quantity;
  final String totalSalesPrice;
  final String disRate;
  final String disAmount;
  final int taAfterDiscount;

  ReplacementDetail({
    required this.productId,
    required this.productName,
    required this.productBarcode,
    required this.unitPrice,
    required this.quantity,
    required this.totalSalesPrice,
    required this.disRate,
    required this.disAmount,
    required this.taAfterDiscount,
  });

  factory ReplacementDetail.fromJson(Map<String, dynamic> json) => ReplacementDetail(
    productId: json["product_id"],
    productName: json["product_name"],
    productBarcode: json["product_barcode"],
    unitPrice: json["unit_price"],
    quantity: json["quantity"],
    totalSalesPrice: json["total_sales_price"],
    disRate: json["dis_rate"],
    disAmount: json["dis_amount"],
    taAfterDiscount: json["ta_after_discount"],
  );

  Map<String, dynamic> toJson() => {
    "product_id": productId,
    "product_name": productName,
    "product_barcode": productBarcode,
    "unit_price": unitPrice,
    "quantity": quantity,
    "total_sales_price": totalSalesPrice,
    "dis_rate": disRate,
    "dis_amount": disAmount,
    "ta_after_discount": taAfterDiscount,
  };
}

class ReplacementSale {
  final String salesBillNo;
  final String salesDate;
  final String totalQuantity;
  final String totalAmount;
  final String discountRate;
  final String discountAmount;
  final String taAfterDiscount;
  final String vatRate;
  final String vatAmount;
  final String deliveryCharge;
  final String processingFee;
  final int grandTotal;
  final int payableAfterReturn;
  final String grandTotalWords;
  final String givenAmount;
  final String changedAmount;
  final dynamic vatChalanNo;
  final List<Payment> paymentSystems;
  final List<Payment> paymentAccounts;
  final List<Collection> collection;

  ReplacementSale({
    required this.salesBillNo,
    required this.salesDate,
    required this.totalQuantity,
    required this.totalAmount,
    required this.discountRate,
    required this.discountAmount,
    required this.taAfterDiscount,
    required this.vatRate,
    required this.vatAmount,
    required this.deliveryCharge,
    required this.processingFee,
    required this.grandTotal,
    required this.payableAfterReturn,
    required this.grandTotalWords,
    required this.givenAmount,
    required this.changedAmount,
    required this.vatChalanNo,
    required this.paymentSystems,
    required this.paymentAccounts,
    required this.collection,
  });

  factory ReplacementSale.fromJson(Map<String, dynamic> json) => ReplacementSale(
    salesBillNo: json["sales_bill_no"],
    salesDate: json["sales_date"],
    totalQuantity: json["total_quantity"],
    totalAmount: json["total_amount"],
    discountRate: json["discount_rate"],
    discountAmount: json["discount_amount"],
    taAfterDiscount: json["ta_after_discount"],
    vatRate: json["vat_rate"],
    vatAmount: json["vat_amount"],
    deliveryCharge: json["delivery_charge"],
    processingFee: json["processing_fee"],
    grandTotal: json["grand_total"],
    payableAfterReturn: json["payable_after_return"],
    grandTotalWords: json["grand_total_words"],
    givenAmount: json["given_amount"],
    changedAmount: json["changed_amount"],
    vatChalanNo: json["vat_chalan_no"],
    paymentSystems: List<Payment>.from(json["payment_systems"].map((x) => Payment.fromJson(x))),
    paymentAccounts: List<Payment>.from(json["payment_accounts"].map((x) => Payment.fromJson(x))),
    collection: List<Collection>.from(json["collection"].map((x) => Collection.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "sales_bill_no": salesBillNo,
    "sales_date": salesDate,
    "total_quantity": totalQuantity,
    "total_amount": totalAmount,
    "discount_rate": discountRate,
    "discount_amount": discountAmount,
    "ta_after_discount": taAfterDiscount,
    "vat_rate": vatRate,
    "vat_amount": vatAmount,
    "delivery_charge": deliveryCharge,
    "processing_fee": processingFee,
    "grand_total": grandTotal,
    "payable_after_return": payableAfterReturn,
    "grand_total_words": grandTotalWords,
    "given_amount": givenAmount,
    "changed_amount": changedAmount,
    "vat_chalan_no": vatChalanNo,
    "payment_systems": List<dynamic>.from(paymentSystems.map((x) => x.toJson())),
    "payment_accounts": List<dynamic>.from(paymentAccounts.map((x) => x.toJson())),
    "collection": List<dynamic>.from(collection.map((x) => x.toJson())),
  };
}

class Collection {
  final int paymentSystemId;
  final String paymentSystemName;
  final int amount;

  Collection({
    required this.paymentSystemId,
    required this.paymentSystemName,
    required this.amount,
  });

  factory Collection.fromJson(Map<String, dynamic> json) => Collection(
    paymentSystemId: json["payment_system_id"],
    paymentSystemName: json["payment_system_name"] ?? "",
    amount: json["amount"],
  );

  Map<String, dynamic> toJson() => {
    "payment_system_id": paymentSystemId,
    "payment_system_name": paymentSystemName,
    "amount": amount,
  };
}

class Payment {
  final String id;
  final String name;

  Payment({
    required this.id,
    required this.name,
  });

  factory Payment.fromJson(Map<String, dynamic> json) => Payment(
    id: json["id"],
    name: json["name"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
  };
}

class Return {
  final String returnBillNo;
  final String originalSalesBillNo;
  final String returnDate;
  final String returnType;
  final String totalReturnQuantity;
  final String totalReturnAmount;
  final String returnDisAmount;
  final dynamic salesDisRate;
  final String taAfterDiscount;
  final String payableReturnAmount;
  final String totalCostAmount;
  final int isActive;
  final int branchId;

  Return({
    required this.returnBillNo,
    required this.originalSalesBillNo,
    required this.returnDate,
    required this.returnType,
    required this.totalReturnQuantity,
    required this.totalReturnAmount,
    required this.returnDisAmount,
    required this.salesDisRate,
    required this.taAfterDiscount,
    required this.payableReturnAmount,
    required this.totalCostAmount,
    required this.isActive,
    required this.branchId,
  });

  factory Return.fromJson(Map<String, dynamic> json) => Return(
    returnBillNo: json["return_bill_no"],
    originalSalesBillNo: json["original_sales_bill_no"],
    returnDate: json["return_date"],
    returnType: json["return_type"],
    totalReturnQuantity: json["total_return_quantity"],
    totalReturnAmount: json["total_return_amount"],
    returnDisAmount: json["return_dis_amount"],
    salesDisRate: json["sales_dis_rate"],
    taAfterDiscount: json["ta_after_discount"],
    payableReturnAmount: json["payable_return_amount"],
    totalCostAmount: json["total_cost_amount"],
    isActive: json["is_active"],
    branchId: json["branch_id"],
  );

  Map<String, dynamic> toJson() => {
    "return_bill_no": returnBillNo,
    "original_sales_bill_no": originalSalesBillNo,
    "return_date": returnDate,
    "return_type": returnType,
    "total_return_quantity": totalReturnQuantity,
    "total_return_amount": totalReturnAmount,
    "return_dis_amount": returnDisAmount,
    "sales_dis_rate": salesDisRate,
    "ta_after_discount": taAfterDiscount,
    "payable_return_amount": payableReturnAmount,
    "total_cost_amount": totalCostAmount,
    "is_active": isActive,
    "branch_id": branchId,
  };
}

class ReturnDetail {
  final int productId;
  final String productName;
  final String productBarcode;
  final String costPrice;
  final String salesPrice;
  final int netRate;
  final String quantity;
  final String disRate;
  final String disAmount;
  final String totalAmount;

  ReturnDetail({
    required this.productId,
    required this.productName,
    required this.productBarcode,
    required this.costPrice,
    required this.salesPrice,
    required this.netRate,
    required this.quantity,
    required this.disRate,
    required this.disAmount,
    required this.totalAmount,
  });

  factory ReturnDetail.fromJson(Map<String, dynamic> json) => ReturnDetail(
    productId: json["product_id"],
    productName: json["product_name"],
    productBarcode: json["product_barcode"],
    costPrice: json["cost_price"],
    salesPrice: json["sales_price"],
    netRate: json["net_rate"],
    quantity: json["quantity"],
    disRate: json["dis_rate"],
    disAmount: json["dis_amount"],
    totalAmount: json["total_amount"],
  );

  Map<String, dynamic> toJson() => {
    "product_id": productId,
    "product_name": productName,
    "product_barcode": productBarcode,
    "cost_price": costPrice,
    "sales_price": salesPrice,
    "net_rate": netRate,
    "quantity": quantity,
    "dis_rate": disRate,
    "dis_amount": disAmount,
    "total_amount": totalAmount,
  };
}
