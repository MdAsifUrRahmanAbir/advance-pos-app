import 'dart:async';

import 'package:advance_pos_app/features/customers/data/models/customers_model.dart';
import 'package:advance_pos_app/features/customers/data/repositories/customers_repository.dart';

import 'customers_fixtures.dart';

typedef CustomersCall = ({int start, int length, String search});

/// In-memory /customer with real paging and search (name, mobile,
/// customer no). [gate] holds the NEXT call only; [nextError] fails the
/// next call only.
class FakeCustomersRepository implements CustomersRepository {
  FakeCustomersRepository([List<Map<String, dynamic>>? rows])
      : rows = rows ?? sampleCustomers();

  final List<Map<String, dynamic>> rows;
  final List<CustomersCall> calls = [];
  Object? nextError;
  Completer<void>? gate;

  @override
  Future<CustomersModel> getCustomers({
    required int start,
    required int length,
    String search = '',
  }) async {
    calls.add((start: start, length: length, search: search));
    final g = gate;
    if (g != null) {
      gate = null;
      await g.future;
    } else {
      await Future<void>.delayed(Duration.zero);
    }
    final error = nextError;
    if (error != null) {
      nextError = null;
      throw error;
    }

    final q = search.toLowerCase();
    final matched = rows.where((r) {
      if (q.isEmpty) return true;
      return [r['customer_name'], r['customer_mobile'], r['customer_no']]
          .any((v) => (v as String).toLowerCase().contains(q));
    }).toList();
    final page = matched.skip(start).take(length).toList();

    return CustomersModel.fromJson({
      'status': 'success',
      'message': '',
      'draw': 1,
      'recordsTotal': matched.length,
      'recordsFiltered': matched.length,
      'recordsShowing': page.length,
      'resultData': page,
    });
  }
}