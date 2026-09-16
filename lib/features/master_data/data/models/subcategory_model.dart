class SubcategoryModel {
  final String status;
  final String message;
  final int recordsTotal;
  final int recordsShowing;
  final List<SubcategoryItem> resultData;

  SubcategoryModel({
    required this.status,
    required this.message,
    required this.recordsTotal,
    required this.recordsShowing,
    required this.resultData,
  });

  factory SubcategoryModel.fromJson(Map<String, dynamic> json) => SubcategoryModel(
    status: json["status"],
    message: json["message"],
    recordsTotal: json["recordsTotal"],
    recordsShowing: json["recordsShowing"],
    resultData: List<SubcategoryItem>.from(json["resultData"].map((x) => SubcategoryItem.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "recordsTotal": recordsTotal,
    "recordsShowing": recordsShowing,
    "resultData": List<dynamic>.from(resultData.map((x) => x.toJson())),
  };
}

class SubcategoryItem {
  final int sl;
  final int id;
  final List<int> prodCatId;
  final String subCategoryName;
  final String subCategoryCode;

  SubcategoryItem({
    required this.sl,
    required this.id,
    required this.prodCatId,
    required this.subCategoryName,
    required this.subCategoryCode,
  });

  factory SubcategoryItem.fromJson(Map<String, dynamic> json) => SubcategoryItem(
    sl: json["sl"],
    id: json["id"],
    // `prod_cat_id` has been observed null/missing on some records —
    // defaulting to an empty list instead of letting `.map` on null
    // throw, which was silently aborting the whole master-data batch.
    prodCatId: json["prod_cat_id"] == null
        ? const []
        : List<int>.from((json["prod_cat_id"] as List).map((x) => x as int)),
    subCategoryName: json["sub_category_name"] ?? '',
    subCategoryCode: json["sub_category_code"] ?? '',
  );

  Map<String, dynamic> toJson() => {
    "sl": sl,
    "id": id,
    "prod_cat_id": List<dynamic>.from(prodCatId.map((x) => x)),
    "sub_category_name": subCategoryName,
    "sub_category_code": subCategoryCode,
  };
}