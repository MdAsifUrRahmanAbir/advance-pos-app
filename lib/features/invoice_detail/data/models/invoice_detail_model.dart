// To parse this JSON data, do
//
//     final invoiceDetailModel = invoiceDetailModelFromJson(jsonString);

import 'dart:convert';

InvoiceDetailModel invoiceDetailModelFromJson(String str) => InvoiceDetailModel.fromJson(json.decode(str));

String invoiceDetailModelToJson(InvoiceDetailModel data) => json.encode(data.toJson());

class InvoiceDetailModel {
  final String status;
  final String message;
  final ResultData resultData;

  InvoiceDetailModel({
    required this.status,
    required this.message,
    required this.resultData,
  });

  factory InvoiceDetailModel.fromJson(Map<String, dynamic> json) => InvoiceDetailModel(
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
  final Sale sale;
  final Payment payment;
  final String referenceNo;
  final String remarks;
  final String customerName;
  final dynamic customerMobile;
  final String salesBy;
  final List<SaleDetail> saleDetails;

  ResultData({
    required this.sale,
    required this.payment,
    required this.referenceNo,
    required this.remarks,
    required this.customerName,
    required this.customerMobile,
    required this.salesBy,
    required this.saleDetails,
  });

  factory ResultData.fromJson(Map<String, dynamic> json) => ResultData(
    sale: Sale.fromJson(json["sale"]),
    payment: Payment.fromJson(json["payment"]),
    referenceNo: json["reference_no"],
    remarks: json["remarks"],
    customerName: json["customer_name"],
    customerMobile: json["customer_mobile"],
    salesBy: json["sales_by"],
    saleDetails: List<SaleDetail>.from(json["saleDetails"].map((x) => SaleDetail.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "sale": sale.toJson(),
    "payment": payment.toJson(),
    "reference_no": referenceNo,
    "remarks": remarks,
    "customer_name": customerName,
    "customer_mobile": customerMobile,
    "sales_by": salesBy,
    "saleDetails": List<dynamic>.from(saleDetails.map((x) => x.toJson())),
  };
}

class Payment {
  final List<PaymentSystem> paymentSystems;
  /// Bank/mobile-banking account used for the payment, when the payment
  /// system is non-cash (e.g. "Bank", "bKash"). Same {id, name} shape as
  /// [PaymentSystem] — reused rather than duplicated. Empty for cash
  /// sales, per the API.
  final List<PaymentSystem> paymentAccounts;
  final List<Collection> collection;

  Payment({
    required this.paymentSystems,
    required this.paymentAccounts,
    required this.collection,
  });

  factory Payment.fromJson(Map<String, dynamic> json) => Payment(
    paymentSystems: List<PaymentSystem>.from(json["payment_systems"].map((x) => PaymentSystem.fromJson(x))),
    paymentAccounts: List<PaymentSystem>.from(json["payment_accounts"].map((x) => PaymentSystem.fromJson(x))),
    collection: List<Collection>.from(json["collection"].map((x) => Collection.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
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
    paymentSystemName: json["payment_system_name"],
    amount: json["amount"],
  );

  Map<String, dynamic> toJson() => {
    "payment_system_id": paymentSystemId,
    "payment_system_name": paymentSystemName,
    "amount": amount,
  };
}

class PaymentSystem {
  final String id;
  final String name;

  PaymentSystem({required this.id, required this.name});

  factory PaymentSystem.fromJson(Map<String, dynamic> json) => PaymentSystem(
    id: json["id"],
    name: json["name"],
  );

  Map<String, dynamic> toJson() => {"id": id, "name": name};
}

class Sale {
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

  Sale({
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
  });

  factory Sale.fromJson(Map<String, dynamic> json) => Sale(
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
  );

  Map<String, dynamic> toJson() => {
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
  };
}

class SaleDetail {
  final int productId;
  final String productBarcode;
  final String productName;
  final String quantity;
  final String unitPrice;
  final int totalPrice;
  final String disRate;
  final String disAmount;
  final int taAfterDiscount;

  SaleDetail({
    required this.productId,
    required this.productBarcode,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    required this.disRate,
    required this.disAmount,
    required this.taAfterDiscount,
  });

  factory SaleDetail.fromJson(Map<String, dynamic> json) => SaleDetail(
    productId: json["product_id"],
    productBarcode: json["product_barcode"],
    productName: json["product_name"],
    quantity: json["quantity"],
    unitPrice: json["unit_price"],
    totalPrice: json["total_price"],
    disRate: json["dis_rate"],
    disAmount: json["dis_amount"],
    taAfterDiscount: json["ta_after_discount"],
  );

  Map<String, dynamic> toJson() => {
    "product_id": productId,
    "product_barcode": productBarcode,
    "product_name": productName,
    "quantity": quantity,
    "unit_price": unitPrice,
    "total_price": totalPrice,
    "dis_rate": disRate,
    "dis_amount": disAmount,
    "ta_after_discount": taAfterDiscount,
  };
}