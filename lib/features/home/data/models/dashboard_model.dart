class DashboardModel {
  final String status;
  final Message message;

  DashboardModel({
    required this.status,
    required this.message,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) => DashboardModel(
    status: json["status"],
    message: Message.fromJson(json["message"]),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message.toJson(),
  };
}

class Message {
  final Today today;
  final ThisMonth thisMonth;
  final Charts charts;
  final TopSelling topSelling;

  Message({
    required this.today,
    required this.thisMonth,
    required this.charts,
    required this.topSelling,
  });

  factory Message.fromJson(Map<String, dynamic> json) => Message(
    today: Today.fromJson(json["today"]),
    thisMonth: ThisMonth.fromJson(json["thisMonth"]),
    charts: Charts.fromJson(json["charts"]),
    topSelling: TopSelling.fromJson(json["topSelling"]),
  );

  Map<String, dynamic> toJson() => {
    "today": today.toJson(),
    "thisMonth": thisMonth.toJson(),
    "charts": charts.toJson(),
    "topSelling": topSelling.toJson(),
  };
}

class Charts {
  final LastsSales last7DaysSales;
  final LastsSales last12MonthsSales;

  Charts({
    required this.last7DaysSales,
    required this.last12MonthsSales,
  });

  factory Charts.fromJson(Map<String, dynamic> json) => Charts(
    last7DaysSales: LastsSales.fromJson(json["last7DaysSales"]),
    last12MonthsSales: LastsSales.fromJson(json["last12MonthsSales"]),
  );

  Map<String, dynamic> toJson() => {
    "last7DaysSales": last7DaysSales.toJson(),
    "last12MonthsSales": last12MonthsSales.toJson(),
  };
}

class LastsSales {
  final String labels;
  final String series;
  final double maxAmount;
  final int count;
  final int quantity;
  final double amount;

  LastsSales({
    required this.labels,
    required this.series,
    required this.maxAmount,
    required this.count,
    required this.quantity,
    required this.amount,
  });

  factory LastsSales.fromJson(Map<String, dynamic> json) => LastsSales(
    labels: json["labels"],
    series: json["series"],
    maxAmount: json["maxAmount"]?.toDouble(),
    count: json["count"],
    quantity: json["quantity"],
    amount: json["amount"]?.toDouble(),
  );

  Map<String, dynamic> toJson() => {
    "labels": labels,
    "series": series,
    "maxAmount": maxAmount,
    "count": count,
    "quantity": quantity,
    "amount": amount,
  };
}

class ThisMonth {
  final SalesReturnClass sales;
  final SalesReturnClass salesReturn;
  final Collection collection;
  final Balance balance;

  ThisMonth({
    required this.sales,
    required this.salesReturn,
    required this.collection,
    required this.balance,
  });

  factory ThisMonth.fromJson(Map<String, dynamic> json) => ThisMonth(
    sales: SalesReturnClass.fromJson(json["sales"]),
    salesReturn: SalesReturnClass.fromJson(json["salesReturn"]),
    collection: Collection.fromJson(json["collection"]),
    balance: Balance.fromJson(json["balance"]),
  );

  Map<String, dynamic> toJson() => {
    "sales": sales.toJson(),
    "salesReturn": salesReturn.toJson(),
    "collection": collection.toJson(),
    "balance": balance.toJson(),
  };
}

class Balance {
  final double balance;
  final double totalReceive;
  final double totalExpense;

  Balance({
    required this.balance,
    required this.totalReceive,
    required this.totalExpense,
  });

  factory Balance.fromJson(Map<String, dynamic> json) => Balance(
    balance: json["balance"]?.toDouble(),
    totalReceive: json["totalReceive"]?.toDouble(),
    totalExpense: json["totalExpense"]?.toDouble(),
  );

  Map<String, dynamic> toJson() => {
    "balance": balance,
    "totalReceive": totalReceive,
    "totalExpense": totalExpense,
  };
}

class Collection {
  final double amount;
  final double vatAmount;
  final double deliveryChargeAmount;
  final double otherChargeAmount;
  final double cashAmount;
  final double bankAmount;
  final double cardAmount;
  final double mobileAmount;
  final double bankCardAmount;

  Collection({
    required this.amount,
    required this.vatAmount,
    required this.deliveryChargeAmount,
    required this.otherChargeAmount,
    required this.cashAmount,
    required this.bankAmount,
    required this.cardAmount,
    required this.mobileAmount,
    required this.bankCardAmount,
  });

  factory Collection.fromJson(Map<String, dynamic> json) => Collection(
    amount: json["amount"]?.toDouble(),
    vatAmount: json["vatAmount"]?.toDouble(),
    deliveryChargeAmount: json["deliveryChargeAmount"]?.toDouble(),
    otherChargeAmount: json["otherChargeAmount"]?.toDouble(),
    cashAmount: json["cashAmount"]?.toDouble(),
    bankAmount: json["bankAmount"]?.toDouble(),
    cardAmount: json["cardAmount"]?.toDouble(),
    mobileAmount: json["mobileAmount"]?.toDouble(),
    bankCardAmount: json["bankCardAmount"]?.toDouble(),
  );

  Map<String, dynamic> toJson() => {
    "amount": amount,
    "vatAmount": vatAmount,
    "deliveryChargeAmount": deliveryChargeAmount,
    "otherChargeAmount": otherChargeAmount,
    "cashAmount": cashAmount,
    "bankAmount": bankAmount,
    "cardAmount": cardAmount,
    "mobileAmount": mobileAmount,
    "bankCardAmount": bankCardAmount,
  };
}

class SalesReturnClass {
  final double amount;
  final int count;
  final int quantity;

  SalesReturnClass({
    required this.amount,
    required this.count,
    required this.quantity,
  });

  factory SalesReturnClass.fromJson(Map<String, dynamic> json) => SalesReturnClass(
    amount: json["amount"]?.toDouble(),
    count: json["count"],
    quantity: json["quantity"],
  );

  Map<String, dynamic> toJson() => {
    "amount": amount,
    "count": count,
    "quantity": quantity,
  };
}

class Today {
  final PurpleSales sales;
  final SalesReturnClass salesReturn;
  final Collection collection;
  final Balance balance;

  Today({
    required this.sales,
    required this.salesReturn,
    required this.collection,
    required this.balance,
  });

  factory Today.fromJson(Map<String, dynamic> json) => Today(
    sales: PurpleSales.fromJson(json["sales"]),
    salesReturn: SalesReturnClass.fromJson(json["salesReturn"]),
    collection: Collection.fromJson(json["collection"]),
    balance: Balance.fromJson(json["balance"]),
  );

  Map<String, dynamic> toJson() => {
    "sales": sales.toJson(),
    "salesReturn": salesReturn.toJson(),
    "collection": collection.toJson(),
    "balance": balance.toJson(),
  };
}

class PurpleSales {
  final double amount;
  final int count;
  final int quantity;
  final double discount;
  final double vat;

  PurpleSales({
    required this.amount,
    required this.count,
    required this.quantity,
    required this.discount,
    required this.vat,
  });

  factory PurpleSales.fromJson(Map<String, dynamic> json) => PurpleSales(
    amount: json["amount"]?.toDouble(),
    count: json["count"],
    quantity: json["quantity"],
    discount: json["discount"]?.toDouble(),
    vat: json["vat"]?.toDouble(),
  );

  Map<String, dynamic> toJson() => {
    "amount": amount,
    "count": count,
    "quantity": quantity,
    "discount": discount,
    "vat": vat,
  };
}

class TopSelling {
  final List<Category> categories;
  final List<String> categoryNames;
  final List<Product> products;

  TopSelling({
    required this.categories,
    required this.categoryNames,
    required this.products,
  });

  factory TopSelling.fromJson(Map<String, dynamic> json) => TopSelling(
    categories: List<Category>.from(json["categories"].map((x) => Category.fromJson(x))),
    categoryNames: List<String>.from(json["categoryNames"].map((x) => x)),
    products: List<Product>.from(json["products"].map((x) => Product.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "categories": List<dynamic>.from(categories.map((x) => x.toJson())),
    "categoryNames": List<dynamic>.from(categoryNames.map((x) => x)),
    "products": List<dynamic>.from(products.map((x) => x.toJson())),
  };
}

class Category {
  final int prodCatId;
  final String catName;
  final int totalQuantity;
  final double totalAmount;

  Category({
    required this.prodCatId,
    required this.catName,
    required this.totalQuantity,
    required this.totalAmount,
  });

  factory Category.fromJson(Map<String, dynamic> json) => Category(
    prodCatId: json["prod_cat_id"],
    catName: json["cat_name"],
    totalQuantity: json["total_quantity"],
    totalAmount: json["total_amount"]?.toDouble(),
  );

  Map<String, dynamic> toJson() => {
    "prod_cat_id": prodCatId,
    "cat_name": catName,
    "total_quantity": totalQuantity,
    "total_amount": totalAmount,
  };
}

class Product {
  final int id;
  final String productName;
  final String prodBarcode;
  final int totalQuantity;
  final double totalAmount;

  Product({
    required this.id,
    required this.productName,
    required this.prodBarcode,
    required this.totalQuantity,
    required this.totalAmount,
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
    id: json["id"],
    productName: json["product_name"],
    prodBarcode: json["prod_barcode"],
    totalQuantity: json["total_quantity"],
    totalAmount: json["total_amount"]?.toDouble(),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "product_name": productName,
    "prod_barcode": prodBarcode,
    "total_quantity": totalQuantity,
    "total_amount": totalAmount,
  };
}
