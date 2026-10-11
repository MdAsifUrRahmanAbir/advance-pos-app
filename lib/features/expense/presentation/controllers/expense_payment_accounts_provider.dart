import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../master_data/presentation/controllers/master_data_controller.dart';

/// Minimal shape the Expense detail needs from master data.
class PaymentAccountOption {
  final int systemId; // matches Detail.paymentSystemId
  final int accountId; // matches Detail.paymentAccId
  final String label; // "providerName [accountNo]"

  const PaymentAccountOption({
    required this.systemId,
    required this.accountId,
    required this.label,
  });
}

/// "EBL Bank [1331030000255]"; just the provider when there is no number.
String formatPaymentAccountLabel(String providerName, String accountNo) {
  final provider = providerName.trim();
  final number = accountNo.trim();
  if (number.isEmpty) return provider;
  if (provider.isEmpty) return number;
  return '$provider [$number]';
}


final expensePaymentAccountsProvider =
Provider.autoDispose<List<PaymentAccountOption>>((ref) {
  final items = ref.watch(
    masterDataControllerProvider.select(
      (s) => s.paymentAccounts,
    ),
  );

  return items
      .map(
        (a) => PaymentAccountOption(
          systemId: a.paymentSystemId,
          accountId: a.id,
          label: formatPaymentAccountLabel(a.providerName, a.accountNo),
        ),
      )
      .toList();
});

/// Filters master data by the head's payment system id, then matches the
/// account id. Falls back to "Account #id" (or "-" when there is no account)
/// while master data is missing or has no match.
String resolvePaymentAccountLabel(
    List<PaymentAccountOption> options, {
      required int systemId,
      required int accountId,
    }) {
  for (final o in options.where((o) => o.systemId == systemId)) {
    if (o.accountId == accountId) return o.label;
  }
  return accountId > 0
      ? AppStrings.expPaymentAccountFallback(accountId)
      : AppStrings.expEmptyValue;
}