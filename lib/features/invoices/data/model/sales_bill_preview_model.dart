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
    status: json["status"],
    message: json["message"],
    printType: json["print_type"],
    company: Company.fromJson(json["company"]),
    branch: Branch.fromJson(json["branch"]),
    counter: Counter.fromJson(json["counter"]),
    invoice: Invoice.fromJson(json["invoice"]),
    productRowData: List<ProductRowDatum>.from(json["productRowData"].map((x) => ProductRowDatum.fromJson(x))),
    summary: Summary.fromJson(json["summary"]),
    payments: List<Payment>.from(json["payments"].map((x) => Payment.fromJson(x))),
    customer: Customer.fromJson(json["customer"]),
    employee: Employee.fromJson(json["employee"]),
    config: Config.fromJson(json["config"]),
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
    branchName: json["branch_name"],
    branchCode: json["branch_code"],
    branchAddr: json["branch_addr"],
    branchPhone: json["branch_phone"],
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
    name: json["name"],
    logoUrl: json["logo_url"],
    logoViewBill: json["logo_view_bill"],
    logoWidthPos: json["logo_width_pos"],
    nameViewBill: json["name_view_bill"],
    brAddViewBill: json["br_add_view_bill"],
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
    returnDayTime: json["return_day_time"],
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
    customerName: json["customer_name"],
    customerMobile: json["customer_mobile"],
    customerNo: json["customer_no"],
    rewardPoints: json["reward_points"],
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
    empName: json["emp_name"],
    empCode: json["emp_code"],
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
    salesBillNo: json["sales_bill_no"],
    vatChalanNo: json["vat_chalan_no"],
    date: json["date"],
    isDuplicate: json["is_duplicate"],
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
    paymentAccId: json["payment_acc_id"],
    paymentName: json["payment_name"],
    collectionAmount: json["collection_amount"],
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
    productId: json["product_id"],
    productName: json["product_name"],
    prodBarcode: json["prod_barcode"],
    unitPrice: json["unit_price"],
    quantity: json["quantity"],
    totalSalesPrice: json["total_sales_price"],
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
  final int grandTotal;
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
    totalAmount: json["total_amount"],
    totalQuantity: json["total_quantity"],
    discountRate: json["discount_rate"],
    discountAmount: json["discount_amount"],
    showDiscountPct: json["show_discount_pct"],
    adjustPoint: json["adjust_point"],
    vatRate: json["vat_rate"],
    vatAmount: json["vat_amount"],
    deliveryCharge: json["delivery_charge"],
    processingFee: json["processing_fee"],
    grandTotal: json["grand_total"],
    grandTotalWords: json["grand_total_words"],
    givenAmount: json["given_amount"],
    changedAmount: json["changed_amount"]?.toDouble(),
    dueAmount: json["due_amount"],
    salesType: json["sales_type"],
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
