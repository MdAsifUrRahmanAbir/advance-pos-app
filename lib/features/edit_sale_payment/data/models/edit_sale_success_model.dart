/// Response of `PUT /sales/edit/:billNo`.
///
/// The docs list `{status, message, id}` but the sample response is
/// `{message, alert-type, sales_bill_no}` — both shapes are accepted.
class EditSaleSuccessModel {
  final String message;
  final String alertType;
  final String? salesBillNo;

  const EditSaleSuccessModel({
    required this.message,
    required this.alertType,
    this.salesBillNo,
  });

  bool get isError => alertType.toLowerCase() == 'error';

  factory EditSaleSuccessModel.fromJson(Map<String, dynamic> json) => EditSaleSuccessModel(
    message: json['message']?.toString() ?? '',
    alertType: (json['alert-type'] ?? json['status'])?.toString() ?? '',
    salesBillNo: (json['sales_bill_no'] ?? json['id'])?.toString(),
  );

  Map<String, dynamic> toJson() => {
    'message': message,
    'alert-type': alertType,
    'sales_bill_no': salesBillNo,
  };
}