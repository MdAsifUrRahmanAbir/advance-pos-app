import 'package:advance_pos_app/features/payment/data/models/sales_success_model.dart';
import 'package:advance_pos_app/features/payment/data/repositories/payment_repository.dart';

/// Records every POST /sales/add payload. [nextError] fails the next
/// call only.
class FakePaymentRepository implements PaymentRepository {
  FakePaymentRepository({this.newBillNo = 'SL0002'});

  final String newBillNo;
  final List<Map<String, dynamic>> calls = [];
  Object? nextError;

  Map<String, dynamic> get lastPayload => calls.last;

  @override
  Future<SalesSuccessModel> completeSale(Map<String, dynamic> data) async {
    calls.add(data);
    await Future<void>.delayed(Duration.zero);
    final error = nextError;
    if (error != null) {
      nextError = null;
      throw error;
    }
    return SalesSuccessModel(
      message: 'Sale completed',
      alertType: 'success',
      salesBillNo: newBillNo,
    );
  }
}