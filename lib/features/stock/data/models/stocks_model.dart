class StocksModel {
  final String status;
  final String message;
  final int draw;
  final int recordsTotal;
  final int recordsFiltered;
  final int recordsShowing;
  final List<ResultDatum> resultData;

  StocksModel({
    required this.status,
    required this.message,
    required this.draw,
    required this.recordsTotal,
    required this.recordsFiltered,
    required this.recordsShowing,
    required this.resultData,
  });

  factory StocksModel.fromJson(Map<String, dynamic> json) => StocksModel(
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
  final ResultDatumProduct product;

  ResultDatum({required this.sl, required this.product});

  factory ResultDatum.fromJson(Map<String, dynamic> json) => ResultDatum(
    sl: json["sl"],
    product: ResultDatumProduct.fromJson(json["product"]),
  );

  Map<String, dynamic> toJson() => {"sl": sl, "product": product.toJson()};
}

class ResultDatumProduct {
  final int id;
  final ProductProduct product;
  final Stock stock;

  ResultDatumProduct({
    required this.id,
    required this.product,
    required this.stock,
  });

  factory ResultDatumProduct.fromJson(Map<String, dynamic> json) =>
      ResultDatumProduct(
        id: json["id"],
        product: ProductProduct.fromJson(json["product"]),
        stock: Stock.fromJson(json["stock"]),
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "product": product.toJson(),
    "stock": stock.toJson(),
  };
}

class ProductProduct {
  final String name;
  final String skuCode;
  final String barcode;
  final String sysBarcode;

  ProductProduct({
    required this.name,
    required this.skuCode,
    required this.barcode,
    required this.sysBarcode,
  });

  factory ProductProduct.fromJson(Map<String, dynamic> json) => ProductProduct(
    name: json["name"],
    skuCode: json["sku_code"],
    barcode: json["barcode"],
    sysBarcode: json["sys_barcode"],
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "sku_code": skuCode,
    "barcode": barcode,
    "sys_barcode": sysBarcode,
  };
}

class Stock {
  final int organizationStock;
  final List<BranchStock> branchStock;

  Stock({required this.organizationStock, required this.branchStock});

  factory Stock.fromJson(Map<String, dynamic> json) => Stock(
    organizationStock: json["organization_stock"],
    branchStock: List<BranchStock>.from(
      json["branch_stock"].map((x) => BranchStock.fromJson(x)),
    ),
  );

  Map<String, dynamic> toJson() => {
    "organization_stock": organizationStock,
    "branch_stock": List<dynamic>.from(branchStock.map((x) => x.toJson())),
  };
}

class BranchStock {
  final int sl;
  final int id;
  final String name;
  final int stock;

  BranchStock({
    required this.sl,
    required this.id,
    required this.name,
    required this.stock,
  });

  factory BranchStock.fromJson(Map<String, dynamic> json) => BranchStock(
    sl: json["sl"],
    id: json["id"],
    name: json["name"] ?? "",
    stock: json["stock"],
  );

  Map<String, dynamic> toJson() => {
    "sl": sl,
    "id": id,
    "name": name,
    "stock": stock,
  };
}
