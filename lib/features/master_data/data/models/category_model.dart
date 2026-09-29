class CategoryModel {
  final String status;
  final String message;
  final int draw;
  final int recordsTotal;
  final int recordsFiltered;
  final int recordsShowing;
  final CategoryResultData resultData;

  CategoryModel({
    required this.status,
    required this.message,
    required this.draw,
    required this.recordsTotal,
    required this.recordsFiltered,
    required this.recordsShowing,
    required this.resultData,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) => CategoryModel(
    status: json["status"],
    message: json["message"],
    draw: json["draw"],
    recordsTotal: json["recordsTotal"],
    recordsFiltered: json["recordsFiltered"],
    recordsShowing: json["recordsShowing"],
    resultData: CategoryResultData.fromJson(json["resultData"]),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "draw": draw,
    "recordsTotal": recordsTotal,
    "recordsFiltered": recordsFiltered,
    "recordsShowing": recordsShowing,
    "resultData": resultData.toJson(),
  };
}

class CategoryResultData {
  final Branch branch;
  final List<TopCategory> topCategories;
  final List<Category> categories;

  CategoryResultData({
    required this.branch,
    required this.topCategories,
    required this.categories,
  });

  factory CategoryResultData.fromJson(Map<String, dynamic> json) => CategoryResultData(
    branch: Branch.fromJson(json["branch"]),
    topCategories: List<TopCategory>.from(json["topCategories"].map((x) => TopCategory.fromJson(x))),
    categories: List<Category>.from(json["categories"].map((x) => Category.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "branch": branch.toJson(),
    "topCategories": List<dynamic>.from(topCategories.map((x) => x.toJson())),
    "categories": List<dynamic>.from(categories.map((x) => x.toJson())),
  };
}

class Branch {
  final int branchId;
  final String branchName;

  Branch({required this.branchId, required this.branchName});

  factory Branch.fromJson(Map<String, dynamic> json) => Branch(
    branchId: json["branch_id"],
    branchName: json["branch_name"],
  );

  Map<String, dynamic> toJson() => {"branch_id": branchId, "branch_name": branchName};
}

class Category {
  final int sl;
  final int id;
  final String categoryName;
  final String categoryCode;
  final List<int> groupId;
  final String groupInfo;
  final String otherCost;
  final String productType;
  final String processingFee;
  final String serialBarcode;

  Category({
    required this.sl,
    required this.id,
    required this.categoryName,
    required this.categoryCode,
    required this.groupId,
    required this.groupInfo,
    required this.otherCost,
    required this.productType,
    required this.processingFee,
    required this.serialBarcode,
  });

  factory Category.fromJson(Map<String, dynamic> json) => Category(
    sl: json["sl"] ?? 0,
    id: json["id"],
    categoryName: json["category_name"],
    categoryCode: json["category_code"],
    groupId: List<int>.from(json["group_id"].map((x) => x)),
    groupInfo: json["group_info"],
    otherCost: json["other_cost"],
    productType: json["product_type"],
    processingFee: json["processing_fee"],
    serialBarcode: json["serial_barcode"],
  );

  Map<String, dynamic> toJson() => {
    "sl": sl,
    "id": id,
    "category_name": categoryName,
    "category_code": categoryCode,
    "group_id": List<dynamic>.from(groupId.map((x) => x)),
    "group_info": groupInfo,
    "other_cost": otherCost,
    "product_type": productType,
    "processing_fee": processingFee,
    "serial_barcode": serialBarcode,
  };
}

class TopCategory {
  final int branchId;
  final String branchName;
  final int categoryId;
  final String categoryName;
  final int totalQuantity;
  final String totalAmount;

  TopCategory({
    required this.branchId,
    required this.branchName,
    required this.categoryId,
    required this.categoryName,
    required this.totalQuantity,
    required this.totalAmount,
  });

  factory TopCategory.fromJson(Map<String, dynamic> json) => TopCategory(
    branchId: json["branch_id"],
    branchName: json["branch_name"],
    categoryId: json["category_id"],
    categoryName: json["category_name"],
    totalQuantity: json["total_quantity"],
    totalAmount: json["total_amount"],
  );

  Map<String, dynamic> toJson() => {
    "branch_id": branchId,
    "branch_name": branchName,
    "category_id": categoryId,
    "category_name": categoryName,
    "total_quantity": totalQuantity,
    "total_amount": totalAmount,
  };
}