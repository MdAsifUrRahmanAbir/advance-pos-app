import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../../../master_data/data/models/common_success_model.dart';
import '../models/expense_form_detail_model.dart';

final expenseFormRepositoryProvider = Provider<ExpenseFormRepository>((ref) {
  return ExpenseFormRepository(ref.watch(apiClientProvider));
});

class ExpenseFormRepository {
  final ApiClient _apiClient;
  ExpenseFormRepository(this._apiClient);

  /// GET /daily_expense/view/{expenseNo} — prefill for edit.
  /// Cache policy: never (transactional data).
  Future<ExpenseFormDetailModel> getExpenseForEdit(String expenseNo) async {
    final response = await _apiClient.get(
      ApiEndpoints.expenseDetails(expenseNo),
    );
    return ExpenseFormDetailModel.fromJson(response.data);
  }

  Future<CommonSuccessModel> saveExpense({
    int? expenseId,
    String? expenseNo,
    required int branchId,
    required String expenseDate,
    required int mainPaymentAccId,
    required List<int> headIds,
    required List<int> paymentAccIds,
    required List<String?> localNarrations,
    required List<num> amounts,
    String? globalNarration,
  }) async {
    final isUpdate = expenseId != null;
    assert(!isUpdate || expenseNo != null, 'expenseNo is required to update');

    final body = {
      if (isUpdate) 'expense_no': expenseNo,
      'branch_id': branchId,
      'expense_date': expenseDate,
      'payment_acc_id_0': mainPaymentAccId,
      'head_id_arr': headIds,
      'payment_acc_id_arr': paymentAccIds,
      'local_narration_id_arr': localNarrations,
      'amount_arr': amounts,
      'global_narration': globalNarration,
    };
    final response = isUpdate
        ? await _apiClient.put(
      ApiEndpoints.expenseEdit('$expenseId'),
      data: body,
    )
        : await _apiClient.post(ApiEndpoints.expenseAdd, data: body);
    return CommonSuccessModel.fromJson(response.data);
  }
}