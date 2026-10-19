import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../master_data/presentation/controllers/master_data_controller.dart';

/// Payment account as the expense form needs it.
// TODO: promote to master_data once a second feature needs the same shape.
class ExpenseFormAccountOption {
  final int systemId; // matches ExpenseFormLine.paymentSystemId
  final int accountId; // matches ExpenseFormLine.paymentAccId
  final String label; // "providerName [accountNo]"

  const ExpenseFormAccountOption({
    required this.systemId,
    required this.accountId,
    required this.label,
  });
}

/// "EBL POS [1331030000255]"; just the provider when there is no number.
String formatExpenseFormAccountLabel(String providerName, String accountNo) {
  final provider = providerName.trim();
  final number = accountNo.trim();
  if (number.isEmpty) return provider;
  if (provider.isEmpty) return number;
  return '$provider [$number]';
}

final expenseFormAccountsProvider =
Provider.autoDispose<List<ExpenseFormAccountOption>>((ref) {
  final items = ref.watch(
    masterDataControllerProvider.select((s) => s.paymentAccounts),
  );
  return items
      .map(
        (a) => ExpenseFormAccountOption(
      systemId: a.paymentSystemId,
      accountId: a.id,
      label: formatExpenseFormAccountLabel(a.providerName, a.accountNo),
    ),
  )
      .toList();
});

/// Matches by system id, then account id. Falls back to "Account #id"
/// (or "-" when there is no account) while master data has no match.
String resolveExpenseFormAccountLabel(
    List<ExpenseFormAccountOption> options, {
      required int systemId,
      required int accountId,
    }) {
  for (final o in options.where((o) => o.systemId == systemId)) {
    if (o.accountId == accountId) return o.label;
  }
  return accountId > 0
      ? AppStrings.expPaymentAccountFallback(accountId)
      : AppStrings.emptyValue;
}