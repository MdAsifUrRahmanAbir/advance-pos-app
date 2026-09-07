class ProductModel {
  final String status;
  final String message;
  final int draw;
  final int recordsTotal;
  final int recordsFiltered;
  final int recordsShowing;
  final List<ResultDatum> resultData;

  ProductModel({
    required this.status,
    required this.message,
    required this.draw,
    required this.recordsTotal,
    required this.recordsFiltered,
    required this.recordsShowing,
    required this.resultData,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) => ProductModel(
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
  final int id;
  final String category;
  final String name;
  final String barcode;
  final String systemBarcode;
  final String skuCode;
  final String salePrice;

  ResultDatum({
    required this.sl,
    required this.id,
    required this.category,
    required this.name,
    required this.barcode,
    required this.systemBarcode,
    required this.skuCode,
    required this.salePrice,
  });

  factory ResultDatum.fromJson(Map<String, dynamic> json) => ResultDatum(
    sl: json["sl"],
    id: json["id"],
    category: json["category"],
    name: json["name"],
    barcode: json["barcode"],
    systemBarcode: json["system_barcode"],
    skuCode: json["sku_code"],
    salePrice: json["sale_price"],
  );

  Map<String, dynamic> toJson() => {
    "sl": sl,
    "id": id,
    "category": category,
    "name": name,
    "barcode": barcode,
    "system_barcode": systemBarcode,
    "sku_code": skuCode,
    "sale_price": salePrice,
  };
}
