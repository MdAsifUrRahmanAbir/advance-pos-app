/// Edit-prefill response for GET /daily_expense/view/{expenseNo}.
/// Trimmed to the fields the form needs.
// TODO: replace with the generated model (add_api_feature.py) from a sample JSON.
class ExpenseFormDetailModel {
  final String status;
  final String message;
  final ExpenseFormDetailData resultData;

  ExpenseFormDetailModel({
    required this.status,
    required this.message,
    required this.resultData,
  });

  factory ExpenseFormDetailModel.fromJson(Map<String, dynamic> json) =>
      ExpenseFormDetailModel(
        status: json["status"],
        message: json["message"],
        resultData: ExpenseFormDetailData.fromJson(json["resultData"]),
      );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "resultData": resultData.toJson(),
  };
}

class ExpenseFormDetailData {
  final int id;
  final String expenseNo;
  final String expenseDate;
  final int branchId;
  final String globalNarration;
  final List<ExpenseFormDetailLine> details;

  ExpenseFormDetailData({
    required this.id,
    required this.expenseNo,
    required this.expenseDate,
    required this.branchId,
    required this.globalNarration,
    required this.details,
  });

  factory ExpenseFormDetailData.fromJson(Map<String, dynamic> json) =>
      ExpenseFormDetailData(
        id: json["id"],
        expenseNo: json["expense_no"],
        expenseDate: json["expense_date"] ?? "",
        branchId: json["branch_id"],
        globalNarration: json["global_narration"] ?? "",
        details: List<ExpenseFormDetailLine>.from(
          (json["details"] ?? []).map((x) => ExpenseFormDetailLine.fromJson(x)),
        ),
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "expense_no": expenseNo,
    "expense_date": expenseDate,
    "branch_id": branchId,
    "global_narration": globalNarration,
    "details": List<dynamic>.from(details.map((x) => x.toJson())),
  };
}

class ExpenseFormDetailLine {
  final int headId;
  final String headName;
  final num amount;
  final int paymentSystemId;
  final int paymentAccId;
  final String localNarration;

  ExpenseFormDetailLine({
    required this.headId,
    required this.headName,
    required this.amount,
    required this.paymentSystemId,
    required this.paymentAccId,
    required this.localNarration,
  });

  factory ExpenseFormDetailLine.fromJson(Map<String, dynamic> json) =>
      ExpenseFormDetailLine(
        headId: json["head_id"],
        headName: json["head_name"] ?? "",
        amount: json["amount"] ?? 0,
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