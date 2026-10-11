
class ExpenseModel {
  final String status;
  final String message;
  final int draw;
  final int recordsTotal;
  final int recordsFiltered;
  final int recordsShowing;
  final List<ResultDatum> resultData;

  ExpenseModel({
    required this.status,
    required this.message,
    required this.draw,
    required this.recordsTotal,
    required this.recordsFiltered,
    required this.recordsShowing,
    required this.resultData,
  });

  factory ExpenseModel.fromJson(Map<String, dynamic> json) => ExpenseModel(
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
  final int id;
  final String expenseNo;
  final String expenseDate;
  final int totalAmount;
  final int branchId;
  final String branchName;
  final List<Detail> details;

  ResultDatum({
    required this.id,
    required this.expenseNo,
    required this.expenseDate,
    required this.totalAmount,
    required this.branchId,
    required this.branchName,
    required this.details,
  });

  factory ResultDatum.fromJson(Map<String, dynamic> json) => ResultDatum(
    id: json["id"],
    expenseNo: json["expense_no"],
    expenseDate: json["expense_date"],
    totalAmount: json["total_amount"],
    branchId: json["branch_id"],
    branchName: json["branch_name"],
    details: List<Detail>.from(json["details"].map((x) => Detail.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "expense_no": expenseNo,
    "expense_date": expenseDate,
    "total_amount": totalAmount,
    "branch_id": branchId,
    "branch_name": branchName,
    "details": List<dynamic>.from(details.map((x) => x.toJson())),
  };
}

class Detail {
  final int headId;
  final int amount;
  final int paymentSystemId;
  final int paymentAccId;
  final dynamic localNarration;

  Detail({
    required this.headId,
    required this.amount,
    required this.paymentSystemId,
    required this.paymentAccId,
    required this.localNarration,
  });

  factory Detail.fromJson(Map<String, dynamic> json) => Detail(
    headId: json["head_id"],
    amount: json["amount"],
    paymentSystemId: json["payment_system_id"],
    paymentAccId: json["payment_acc_id"],
    localNarration: json["local_narration"],
  );

  Map<String, dynamic> toJson() => {
    "head_id": headId,
    "amount": amount,
    "payment_system_id": paymentSystemId,
    "payment_acc_id": paymentAccId,
    "local_narration": localNarration,
  };
}
