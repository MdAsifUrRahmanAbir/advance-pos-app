import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../../../master_data/data/models/common_success_model.dart';
import '../model/expense_detail_model.dart';
import '../model/expense_model.dart';
// import '../models/expense_detail_model.dart' show ExpenseDetailModel;
// import '../models/expense_model.dart' show ExpenseModel;

final expenseRepositoryProvider = Provider<ExpenseRepository>((ref) {
  return ExpenseRepository(ref.watch(apiClientProvider));
});

class ExpenseRepository {
  final ApiClient _apiClient;
  ExpenseRepository(this._apiClient);

  /// GET /daily_expense?start=&length=&branch_id=&search=&from_date=&to_date=
  /// Dates are 'YYYY-MM-DD'. Optional params are omitted when empty.
  Future<ExpenseModel> getExpenses({
    required int start,
    required int length,
    required int branchId,
    String? search,
    String? fromDate,
    String? toDate,
  }) async {
    final response = await _apiClient.get(
      ApiEndpoints.expense,
      queryParameters: {
        'start': start,
        'length': length,
        'branch_id': branchId,
        if (search != null && search.isNotEmpty) 'search': search,
        if (fromDate != null && toDate != null) 'dateRange': "$fromDate to $toDate"
        // 'from_date': ?fromDate,
        // 'to_date': ?toDate,
      },
    );
    return ExpenseModel.fromJson(response.data);
  }

  Future<ExpenseDetailModel> getExpenseDetail(String expenseNo) async {
    final response = await _apiClient.get(
      ApiEndpoints.expenseDetails(expenseNo),
    );
    return ExpenseDetailModel.fromJson(response.data);
  }

  /// DELETE /daily_expense/delete/{expenseNo}
  /// Cache policy: never (transactional data).
  Future<CommonSuccessModel> deleteExpense(String expenseNo) async {
    final response = await _apiClient.delete(
      ApiEndpoints.expenseDelete(expenseNo),
    );
    return CommonSuccessModel.fromJson(response.data);
  }

  /// Create (expenseNo == null) -> POST /daily_expense/add
  /// Edit   (expenseNo != null) -> PUT  /daily_expense/edit/{expenseNo}
  /// Cache policy: never. [expenseDate] is 'DD-MM-YYYY'. The four *_arr
  /// lists are parallel (one entry per expense line).
  // TODO: confirm the edit endpoint's HTTP method and body with the backend.
  Future<CommonSuccessModel> saveExpense({
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
    final body = {
      'branch_id': branchId,
      'expense_date': expenseDate,
      'payment_acc_id_0': mainPaymentAccId,
      'head_id_arr': headIds,
      'payment_acc_id_arr': paymentAccIds,
      'local_narration_id_arr': localNarrations,
      'amount_arr': amounts,
      'global_narration': globalNarration,
    };
    final response = expenseNo == null
        ? await _apiClient.post(ApiEndpoints.expenseAdd, data: body)
        : await _apiClient.put(
      ApiEndpoints.expenseEdit(expenseNo),
      data: body,
    );
    return CommonSuccessModel.fromJson(response.data);
  }
}