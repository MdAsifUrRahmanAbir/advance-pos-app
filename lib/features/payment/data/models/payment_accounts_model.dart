class PaymentAccountsModel {
  final String status;
  final String message;
  final int recordsTotal;
  final int recordsShowing;
  final List<ResultDatum> resultData;

  PaymentAccountsModel({
    required this.status,
    required this.message,
    required this.recordsTotal,
    required this.recordsShowing,
    required this.resultData,
  });

  factory PaymentAccountsModel.fromJson(Map<String, dynamic> json) => PaymentAccountsModel(
    status: json["status"],
    message: json["message"],
    recordsTotal: json["recordsTotal"],
    recordsShowing: json["recordsShowing"],
    resultData: List<ResultDatum>.from(json["resultData"].map((x) => ResultDatum.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "recordsTotal": recordsTotal,
    "recordsShowing": recordsShowing,
    "resultData": List<dynamic>.from(resultData.map((x) => x.toJson())),
  };
}

class ResultDatum {
  final int id;
  final String status;
  final String providerName;
  final String accHolderName;
  final String accountNo;
  final int ledgerId;
  final int paymentSystemId;
  final String ledger;
  final PaymentSystem paymentSystem;

  ResultDatum({
    required this.id,
    required this.status,
    required this.providerName,
    required this.accHolderName,
    required this.accountNo,
    required this.ledgerId,
    required this.paymentSystemId,
    required this.ledger,
    required this.paymentSystem,
  });

  factory ResultDatum.fromJson(Map<String, dynamic> json) => ResultDatum(
    id: json["id"],
    status: json["status"],
    providerName: json["provider_name"],
    accHolderName: json["acc_holder_name"] ?? "",
    accountNo: json["account_no"] ?? "",
    ledgerId: json["ledger_id"],
    paymentSystemId: json["payment_system_id"],
    ledger: json["ledger"],
    paymentSystem: PaymentSystem.fromJson(json["payment_system"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "status": status,
    "provider_name": providerName,
    "acc_holder_name": accHolderName,
    "account_no": accountNo,
    "ledger_id": ledgerId,
    "payment_system_id": paymentSystemId,
    "ledger": ledger,
    "payment_system": paymentSystem.toJson(),
  };
}

class PaymentSystem {
  final int id;
  final String paymentSystemName;
  final String shortName;
  final String status;
  final int isActive;

  PaymentSystem({
    required this.id,
    required this.paymentSystemName,
    required this.shortName,
    required this.status,
    required this.isActive,
  });

  factory PaymentSystem.fromJson(Map<String, dynamic> json) => PaymentSystem(
    id: json["id"],
    paymentSystemName: json["payment_system_name"],
    shortName: json["short_name"],
    status: json["status"],
    isActive: json["is_active"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "payment_system_name": paymentSystemName,
    "short_name": shortName,
    "status": status,
    "is_active": isActive,
  };
}
