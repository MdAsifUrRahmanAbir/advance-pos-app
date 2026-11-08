import 'package:advance_pos_app/features/invoices/data/model/invoices_model.dart';
import 'package:advance_pos_app/features/invoices/data/repositories/invoices_repository.dart';
import 'package:advance_pos_app/features/master_data/data/models/common_success_model.dart';

import 'invoice_fixtures.dart';

/// In-memory backend for screen and integration tests: real paging,
/// search and delete over [rows], plus one-shot error injection.
class FakeInvoicesRepository implements InvoicesRepository {
  FakeInvoicesRepository(this.rows);

  final List<Map<String, dynamic>> rows;

  /// Thrown by the next getInvoices call only.
  Object? nextError;
  int getCalls = 0;

  @override
  Future<InvoicesModel> getInvoices({
    required int start,
    required int length,
    String search = '',
    int? groupId,
    int? categoryId,
    int? subCategoryId,
    int? brandId,
    int? customerId,
    int? employeeId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    getCalls++;
    await Future<void>.delayed(Duration.zero);
    final error = nextError;
    if (error != null) {
      nextError = null;
      throw error;
    }
    final q = search.toLowerCase();
    final matched = rows.where((r) {
      if (q.isEmpty) return true;
      return (r['sales_bill_no'] as String).toLowerCase().contains(q) ||
          (r['customer_name'] as String).toLowerCase().contains(q);
    }).toList();
    return invoicesPage(
      matched.skip(start).take(length).toList(),
      recordsFiltered: matched.length,
    );
  }

  @override
  Future<CommonSuccessModel> deleteCommonSuccess(String billNo) async {
    rows.removeWhere((r) => r['sales_bill_no'] == billNo);
    return CommonSuccessModel(status: 'success', message: 'Deleted');
  }
}