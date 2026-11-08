import 'dart:async';

import 'package:advance_pos_app/features/expense/data/model/expense_detail_model.dart';
import 'package:advance_pos_app/features/expense/data/model/expense_model.dart';
import 'package:advance_pos_app/features/expense/data/repositories/expense_repository.dart';
import 'package:advance_pos_app/features/master_data/data/models/common_success_model.dart';

import 'expense_fixtures.dart';

typedef ExpenseCall = ({
int start,
int length,
String? search,
String? fromDate,
String? toDate,
});

/// In-memory /daily_expense with paging, search, date range and delete.
/// [gate] holds the next list call; `next*Error` fail the next matching
/// call only.
class FakeExpenseRepository implements ExpenseRepository {
  FakeExpenseRepository({int count = 25})
      : _heads = sampleHeads(count: count);

  final Map<int, List<Map<String, dynamic>>> _heads;
  final List<ExpenseCall> calls = [];
  final List<String> detailLoads = [];
  final List<String> deleted = [];

  Object? nextListError;
  Object? nextDetailError;
  Object? nextDeleteError;
  Completer<void>? gate;

  Future<void> _wait() async {
    final g = gate;
    if (g != null) {
      gate = null;
      await g.future;
    } else {
      await Future<void>.delayed(Duration.zero);
    }
  }

  Object? _take(Object? Function() read, void Function() clear) {
    final e = read();
    if (e != null) clear();
    return e;
  }

  @override
  Future<ExpenseModel> getExpenses({
    required int start,
    required int length,
    String? search,
    String? fromDate,
    String? toDate,
  }) async {
    calls.add((
    start: start,
    length: length,
    search: search,
    fromDate: fromDate,
    toDate: toDate,
    ));
    await _wait();
    final error = _take(() => nextListError, () => nextListError = null);
    if (error != null) throw error;

    final q = (search ?? '').toLowerCase();
    final ids = _heads.keys.where((id) {
      if (q.isNotEmpty && !expenseNoFor(id).toLowerCase().contains(q)) {
        return false;
      }
      final d = dateFor(id); // ISO dates compare as strings
      if (fromDate != null && d.compareTo(fromDate) < 0) return false;
      if (toDate != null && d.compareTo(toDate) > 0) return false;
      return true;
    }).toList();
    final page = ids.skip(start).take(length).toList();

    return ExpenseModel.fromJson({
      'status': 'success',
      'message': '',
      'draw': 1,
      'recordsTotal': ids.length,
      'recordsFiltered': ids.length,
      'recordsShowing': page.length,
      'resultData': [
        for (final id in page)
          expenseRowJson(id: id, date: dateFor(id), heads: _heads[id]!),
      ],
    });
  }

  @override
  Future<ExpenseDetailModel> getExpenseDetail(String expenseNo) async {
    detailLoads.add(expenseNo);
    await _wait();
    final error = _take(() => nextDetailError, () => nextDetailError = null);
    if (error != null) throw error;
    final id = _heads.keys.firstWhere((i) => expenseNoFor(i) == expenseNo);
    return ExpenseDetailModel.fromJson(expenseDetailJson(id, _heads[id]!));
  }

  @override
  Future<CommonSuccessModel> deleteExpense(String expenseNo) async {
    await Future<void>.delayed(Duration.zero);
    final error = _take(() => nextDeleteError, () => nextDeleteError = null);
    if (error != null) throw error;
    deleted.add(expenseNo);
    _heads.removeWhere((id, _) => expenseNoFor(id) == expenseNo);
    return CommonSuccessModel(status: 'success', message: 'Deleted');
  }
}