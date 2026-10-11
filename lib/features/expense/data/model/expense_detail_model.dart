
class ExpenseDetailModel {
  final String status;
  final String message;
  final ResultData resultData;

  ExpenseDetailModel({
    required this.status,
    required this.message,
    required this.resultData,
  });

  factory ExpenseDetailModel.fromJson(Map<String, dynamic> json) => ExpenseDetailModel(
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
  final int id;
  final String expenseNo;
  final String expenseDate;
  final int totalAmount;
  final int branchId;
  final String branchName;
  final String globalNarration;
  final List<Detail> details;
  final String entryBy;
  final String entryDateTime;

  ResultData({
    required this.id,
    required this.expenseNo,
    required this.expenseDate,
    required this.totalAmount,
    required this.branchId,
    required this.branchName,
    required this.globalNarration,
    required this.details,
    required this.entryBy,
    required this.entryDateTime,
  });

  factory ResultData.fromJson(Map<String, dynamic> json) => ResultData(
    id: json["id"],
    expenseNo: json["expense_no"],
    expenseDate: json["expense_date"],
    totalAmount: json["total_amount"],
    branchId: json["branch_id"],
    branchName: json["branch_name"],
    globalNarration: json["global_narration"],
    details: List<Detail>.from(json["details"].map((x) => Detail.fromJson(x))),
    entryBy: json["entry_by"] ?? "",
    entryDateTime: json["entry_date_time"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "expense_no": expenseNo,
    "expense_date": expenseDate,
    "total_amount": totalAmount,
    "branch_id": branchId,
    "branch_name": branchName,
    "global_narration": globalNarration,
    "details": List<dynamic>.from(details.map((x) => x.toJson())),
    "entry_by": entryBy,
    "entry_date_time": entryDateTime,
  };
}

class Detail {
  final int headId;
  final String headName;
  final int amount;
  final int paymentSystemId;
  final int paymentAccId;
  final String localNarration;

  Detail({
    required this.headId,
    required this.headName,
    required this.amount,
    required this.paymentSystemId,
    required this.paymentAccId,
    required this.localNarration,
  });

  factory Detail.fromJson(Map<String, dynamic> json) => Detail(
    headId: json["head_id"],
    headName: json["head_name"],
    amount: json["amount"],
    paymentSystemId: json["payment_system_id"],
    paymentAccId: json["payment_acc_id"],
    localNarration: json["local_narration"] ?? "",
  );

  Map<String, dynamic> toJson() => {
    "head_id": headId,
    "head_name": headName,
    "amount": amount,
    "payment_system_id": paymentSystemId,
    "payment_acc_id": paymentAccId,
    "local_narration": localNarration,
  };
}
