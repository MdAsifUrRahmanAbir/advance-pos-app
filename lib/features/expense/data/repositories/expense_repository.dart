import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
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
        'from_date': ?fromDate,
        'to_date': ?toDate,
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
}