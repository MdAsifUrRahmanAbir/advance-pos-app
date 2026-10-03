import '../../../master_data/data/models/payment_accounts_model.dart' as pa;

/// Unique payment systems derived from the accounts list, in order of
/// first appearance. The accounts endpoint is the only source of truth.
List<pa.PaymentSystem> paymentSystemsFrom(List<pa.ResultDatum> accounts) {
  final seen = <int>{};
  return [
    for (final a in accounts)
      if (seen.add(a.paymentSystem.id)) a.paymentSystem,
  ];
}