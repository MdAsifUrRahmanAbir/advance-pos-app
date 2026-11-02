// Null-safe parsing: the bill API may send null (or `[]` instead of `{}`)
// for any object or field — e.g. `"employee": null`. Missing objects
// become empty ones, missing text becomes '' (hidden on the receipt),
// missing numbers become 0.

Map<String, dynamic> _map(dynamic v) =>
    v is Map ? Map<String, dynamic>.from(v) : <String, dynamic>{};

List<dynamic> _list(dynamic v) => v is List ? v : const [];

String _str(dynamic v) => v == null ? '' : v.toString();

int _int(dynamic v) =>
    v is num ? v.toInt() : int.tryParse(_str(v).replaceAll(',', '')) ?? 0;

num _num(dynamic v) =>
    v is num ? v : num.tryParse(_str(v).replaceAll(',', '')) ?? 0;

double _double(dynamic v) => _num(v).toDouble();

bool _bool(dynamic v) => v == true || v == 1 || v == '1' || v == 'true';

class SalesBillPreviewModel {
  final String status;
  final String message;
  final dynamic printType;
  final Company company;
  final Branch branch;
  final Counter counter;
  final Invoice invoice;
  final List<ProductRowDatum> productRowData;
  final Summary summary;
  final List<Payment> payments;
  final Customer customer;
  final Employee employee;
  final Config config;

  SalesBillPreviewModel({
    required this.status,
    required this.message,
    required this.printType,
    required this.company,
    required this.branch,
    required this.counter,
    required this.invoice,
    required this.productRowData,
    required this.summary,
    required this.payments,
    required this.customer,
    required this.employee,
    required this.config,
  });

  factory SalesBillPreviewModel.fromJson(Map<String, dynamic> json) => SalesBillPreviewModel(
    status: _str(json["status"]),
    message: _str(json["message"]),
    printType: json["print_type"],
    company: Company.fromJson(_map(json["company"])),
    branch: Branch.fromJson(_map(json["branch"])),
    counter: Counter.fromJson(_map(json["counter"])),
    invoice: Invoice.fromJson(_map(json["invoice"])),
    productRowData: _list(json["productRowData"])
        .map((x) => ProductRowDatum.fromJson(_map(x)))
        .toList(),
    summary: Summary.fromJson(_map(json["summary"])),
    payments: _list(json["payments"]).map((x) => Payment.fromJson(_map(x))).toList(),
    customer: Customer.fromJson(_map(json["customer"])),
    employee: Employee.fromJson(_map(json["employee"])),
    config: Config.fromJson(_map(json["config"])),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "print_type": printType,
    "company": company.toJson(),
    "branch": branch.toJson(),
    "counter": counter.toJson(),
    "invoice": invoice.toJson(),
    "productRowData": List<dynamic>.from(productRowData.map((x) => x.toJson())),
    "summary": summary.toJson(),
    "payments": List<dynamic>.from(payments.map((x) => x.toJson())),
    "customer": customer.toJson(),
    "employee": employee.toJson(),
    "config": config.toJson(),
  };
}

class Branch {
  final String branchName;
  final dynamic branchCode;
  final String branchAddr;
  final String branchPhone;

  Branch({
    required this.branchName,
    required this.branchCode,
    required this.branchAddr,
    required this.branchPhone,
  });

  factory Branch.fromJson(Map<String, dynamic> json) => Branch(
    branchName: _str(json["branch_name"]),
    branchCode: json["branch_code"],
    branchAddr: _str(json["branch_addr"]),
    branchPhone: _str(json["branch_phone"]),
  );

  Map<String, dynamic> toJson() => {
    "branch_name": branchName,
    "branch_code": branchCode,
    "branch_addr": branchAddr,
    "branch_phone": branchPhone,
  };
}

class Company {
  final String name;
  final String logoUrl;
  final int logoViewBill;
  final String logoWidthPos;
  final int nameViewBill;
  final int brAddViewBill;

  Company({
    required this.name,
    required this.logoUrl,
    required this.logoViewBill,
    required this.logoWidthPos,
    required this.nameViewBill,
    required this.brAddViewBill,
  });

  factory Company.fromJson(Map<String, dynamic> json) => Company(
    name: _str(json["name"]),
    logoUrl: _str(json["logo_url"]),
    logoViewBill: _int(json["logo_view_bill"]),
    logoWidthPos: _str(json["logo_width_pos"]),
    nameViewBill: _int(json["name_view_bill"]),
    brAddViewBill: _int(json["br_add_view_bill"]),
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "logo_url": logoUrl,
    "logo_view_bill": logoViewBill,
    "logo_width_pos": logoWidthPos,
    "name_view_bill": nameViewBill,
    "br_add_view_bill": brAddViewBill,
  };
}

class Config {
  final String returnDayTime;
  final dynamic termsAndConditions;

  Config({
    required this.returnDayTime,
    required this.termsAndConditions,
  });

  factory Config.fromJson(Map<String, dynamic> json) => Config(
    returnDayTime: _str(json["return_day_time"]),
    termsAndConditions: json["terms_and_conditions"],
  );

  Map<String, dynamic> toJson() => {
    "return_day_time": returnDayTime,
    "terms_and_conditions": termsAndConditions,
  };
}

class Counter {
  final dynamic counterName;

  Counter({
    required this.counterName,
  });

  factory Counter.fromJson(Map<String, dynamic> json) => Counter(
    counterName: json["counter_name"],
  );

  Map<String, dynamic> toJson() => {
    "counter_name": counterName,
  };
}

class Customer {
  final String customerName;
  final String customerMobile;
  final String customerNo;
  final int rewardPoints;

  Customer({
    required this.customerName,
    required this.customerMobile,
    required this.customerNo,
    required this.rewardPoints,
  });

  factory Customer.fromJson(Map<String, dynamic> json) => Customer(
    customerName: _str(json["customer_name"]),
    customerMobile: _str(json["customer_mobile"]),
    customerNo: _str(json["customer_no"]),
    rewardPoints: _int(json["reward_points"]),
  );

  Map<String, dynamic> toJson() => {
    "customer_name": customerName,
    "customer_mobile": customerMobile,
    "customer_no": customerNo,
    "reward_points": rewardPoints,
  };
}

class Employee {
  final String empName;
  final String empCode;

  Employee({
    required this.empName,
    required this.empCode,
  });

  factory Employee.fromJson(Map<String, dynamic> json) => Employee(
    empName: _str(json["emp_name"]),
    empCode: _str(json["emp_code"]),
  );

  Map<String, dynamic> toJson() => {
    "emp_name": empName,
    "emp_code": empCode,
  };
}

class Invoice {
  final String salesBillNo;
  final dynamic vatChalanNo;
  final String date;
  final bool isDuplicate;

  Invoice({
    required this.salesBillNo,
    required this.vatChalanNo,
    required this.date,
    required this.isDuplicate,
  });

  factory Invoice.fromJson(Map<String, dynamic> json) => Invoice(
    salesBillNo: _str(json["sales_bill_no"]),
    vatChalanNo: json["vat_chalan_no"],
    date: _str(json["date"]),
    isDuplicate: _bool(json["is_duplicate"]),
  );

  Map<String, dynamic> toJson() => {
    "sales_bill_no": salesBillNo,
    "vat_chalan_no": vatChalanNo,
    "date": date,
    "is_duplicate": isDuplicate,
  };
}

class Payment {
  final int paymentAccId;
  final dynamic paymentName;
  final String collectionAmount;

  Payment({
    required this.paymentAccId,
    required this.paymentName,
    required this.collectionAmount,
  });

  factory Payment.fromJson(Map<String, dynamic> json) => Payment(
    paymentAccId: _int(json["payment_acc_id"]),
    paymentName: json["payment_name"],
    collectionAmount: _str(json["collection_amount"]),
  );

  Map<String, dynamic> toJson() => {
    "payment_acc_id": paymentAccId,
    "payment_name": paymentName,
    "collection_amount": collectionAmount,
  };
}

class ProductRowDatum {
  final int productId;
  final String productName;
  final String prodBarcode;
  final String unitPrice;
  final String quantity;
  final String totalSalesPrice;

  ProductRowDatum({
    required this.productId,
    required this.productName,
    required this.prodBarcode,
    required this.unitPrice,
    required this.quantity,
    required this.totalSalesPrice,
  });

  factory ProductRowDatum.fromJson(Map<String, dynamic> json) => ProductRowDatum(
    productId: _int(json["product_id"]),
    productName: _str(json["product_name"]),
    prodBarcode: _str(json["prod_barcode"]),
    unitPrice: _str(json["unit_price"]),
    quantity: _str(json["quantity"]),
    totalSalesPrice: _str(json["total_sales_price"]),
  );

  Map<String, dynamic> toJson() => {
    "product_id": productId,
    "product_name": productName,
    "prod_barcode": prodBarcode,
    "unit_price": unitPrice,
    "quantity": quantity,
    "total_sales_price": totalSalesPrice,
  };
}

class Summary {
  final String totalAmount;
  final String totalQuantity;
  final String discountRate;
  final String discountAmount;
  final bool showDiscountPct;
  final String adjustPoint;
  final String vatRate;
  final String vatAmount;
  final String deliveryCharge;
  final String processingFee;
  final num grandTotal;
  final String grandTotalWords;
  final String givenAmount;
  final double changedAmount;
  final dynamic dueAmount;
  final String salesType;

  Summary({
    required this.totalAmount,
    required this.totalQuantity,
    required this.discountRate,
    required this.discountAmount,
    required this.showDiscountPct,
    required this.adjustPoint,
    required this.vatRate,
    required this.vatAmount,
    required this.deliveryCharge,
    required this.processingFee,
    required this.grandTotal,
    required this.grandTotalWords,
    required this.givenAmount,
    required this.changedAmount,
    required this.dueAmount,
    required this.salesType,
  });

  factory Summary.fromJson(Map<String, dynamic> json) => Summary(
    totalAmount: _str(json["total_amount"]),
    totalQuantity: _str(json["total_quantity"]),
    discountRate: _str(json["discount_rate"]),
    discountAmount: _str(json["discount_amount"]),
    showDiscountPct: _bool(json["show_discount_pct"]),
    adjustPoint: _str(json["adjust_point"]),
    vatRate: _str(json["vat_rate"]),
    vatAmount: _str(json["vat_amount"]),
    deliveryCharge: _str(json["delivery_charge"]),
    processingFee: _str(json["processing_fee"]),
    grandTotal: _num(json["grand_total"]),
    grandTotalWords: _str(json["grand_total_words"]),
    givenAmount: _str(json["given_amount"]),
    changedAmount: _double(json["changed_amount"]),
    dueAmount: json["due_amount"],
    salesType: _str(json["sales_type"]),
  );

  Map<String, dynamic> toJson() => {
    "total_amount": totalAmount,
    "total_quantity": totalQuantity,
    "discount_rate": discountRate,
    "discount_amount": discountAmount,
    "show_discount_pct": showDiscountPct,
    "adjust_point": adjustPoint,
    "vat_rate": vatRate,
    "vat_amount": vatAmount,
    "delivery_charge": deliveryCharge,
    "processing_fee": processingFee,
    "grand_total": grandTotal,
    "grand_total_words": grandTotalWords,
    "given_amount": givenAmount,
    "changed_amount": changedAmount,
    "due_amount": dueAmount,
    "sales_type": salesType,
  };
}