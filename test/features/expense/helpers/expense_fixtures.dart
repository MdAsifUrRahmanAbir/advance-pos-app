import 'package:advance_pos_app/features/expense/presentation/states/expense_format.dart';

DateTime get _today {
  final n = DateTime.now();
  return DateTime(n.year, n.month, n.day);
}

String get todayApi => ExpenseFormat.apiDate(_today);
String get yesterdayApi =>
    ExpenseFormat.apiDate(_today.subtract(const Duration(days: 1)));
const String oldDateApi = '2026-01-15';

String expenseNoFor(int i) => 'EXP-${i.toString().padLeft(4, '0')}';

/// One /daily_expense list row.
Map<String, dynamic> expenseRowJson({
  required int id,
  required String date,
  required List<Map<String, dynamic>> heads,
}) =>
    {
      'id': id,
      'expense_no': expenseNoFor(id),
      'expense_date': date,
      'total_amount': heads.fold<int>(0, (s, h) => s + (h['amount'] as int)),
      'branch_id': 1,
      'branch_name': 'Dhanmondi',
      'details': [
        for (final h in heads)
          {
            'head_id': h['head_id'],
            'amount': h['amount'],
            'payment_system_id': h['payment_system_id'],
            'payment_acc_id': h['payment_acc_id'],
            'local_narration': h['local_narration'],
          },
      ],
    };

/// Heads carry head_name too (only the detail endpoint returns it).
Map<String, dynamic> head(
    int headId,
    String name,
    int amount, {
      required int systemId,
      required int accountId,
      String? narration,
    }) =>
    {
      'head_id': headId,
      'head_name': name,
      'amount': amount,
      'payment_system_id': systemId,
      'payment_acc_id': accountId,
      'local_narration': narration,
    };

/// Exactly [count] expenses: EXP-0001 (today, two heads: Rent by Cash +
/// Utility by bKash), EXP-0002 (yesterday), then old fillers. 25 by
/// default; 0 means no expenses at all.
Map<int, List<Map<String, dynamic>>> sampleHeads({int count = 25}) => {
  if (count >= 1)
    1: [
      head(1, 'Rent', 1000,
          systemId: 1, accountId: 11, narration: 'November'),
      head(2, 'Utility', 500, systemId: 2, accountId: 21),
    ],
  if (count >= 2)
    2: [head(3, 'Tea & Snacks', 250, systemId: 1, accountId: 11)],
  for (var i = 3; i <= count; i++)
    i: [head(4, 'Misc', 100, systemId: 1, accountId: 11)],
};

String dateFor(int id) => switch (id) {
  1 => todayApi,
  2 => yesterdayApi,
  _ => oldDateApi,
};

/// GET /daily_expense/view/{no}
Map<String, dynamic> expenseDetailJson(
    int id,
    List<Map<String, dynamic>> heads,
    ) =>
    {
      'status': 'success',
      'message': '',
      'resultData': {
        'id': id,
        'expense_no': expenseNoFor(id),
        'expense_date': dateFor(id),
        'total_amount': heads.fold<int>(0, (s, h) => s + (h['amount'] as int)),
        'branch_id': 1,
        'branch_name': 'Dhanmondi',
        'global_narration': 'Monthly costs',
        'details': heads,
        'entry_by': 'Admin',
        'entry_date_time': '${dateFor(id)} 10:30',
      },
    };