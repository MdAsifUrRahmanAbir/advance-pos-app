
class AddCustomerModel {
  final String message;
  final String alertType;
  final String id;
  final String customerName;
  final int branchId;
  final bool syncNeeded;

  AddCustomerModel({
    required this.message,
    required this.alertType,
    required this.id,
    required this.customerName,
    required this.branchId,
    required this.syncNeeded,
  });

  factory AddCustomerModel.fromJson(Map<String, dynamic> json) => AddCustomerModel(
    message: json["message"],
    alertType: json["alert-type"],
    id: json["id"],
    customerName: json["customer_name"],
    branchId: json["branch_id"],
    syncNeeded: json["syncNeeded"],
  );

  Map<String, dynamic> toJson() => {
    "message": message,
    "alert-type": alertType,
    "id": id,
    "customer_name": customerName,
    "branch_id": branchId,
    "syncNeeded": syncNeeded,
  };
}
