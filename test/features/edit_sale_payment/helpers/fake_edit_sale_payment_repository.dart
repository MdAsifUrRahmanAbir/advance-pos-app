import 'package:advance_pos_app/features/edit_sale_payment/data/models/edit_sale_success_model.dart';
import 'package:advance_pos_app/features/edit_sale_payment/data/repositories/edit_sale_payment_repository.dart';

/// Records every PUT /sales/edit payload. [nextError] fails the next
/// call only (the real repository also raises `alert-type: error` as an
/// ApiException).
class FakeEditSalePaymentRepository implements EditSalePaymentRepository {
  final List<({String billNo, Map<String, dynamic> data})> calls = [];
  Object? nextError;

  Map<String, dynamic> get lastPayload => calls.last.data;

  @override
  Future<EditSaleSuccessModel> updateSale(
      String billNo,
      Map<String, dynamic> data,
      ) async {
    calls.add((billNo: billNo, data: data));
    await Future<void>.delayed(Duration.zero);
    final error = nextError;
    if (error != null) {
      nextError = null;
      throw error;
    }
    return EditSaleSuccessModel(
      message: 'Sale updated',
      alertType: 'success',
      salesBillNo: billNo,
    );
  }
}