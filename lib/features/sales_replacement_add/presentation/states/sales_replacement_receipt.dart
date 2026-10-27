import '../../../payment/presentation/states/payment_state.dart'
    show ReceiptLineItem;

/// Everything the success sheet shows, shares and prints, captured at the
/// moment the replacement was created so later edits can't change it.
class SalesReplacementReceipt {
  /// The new replacement's own bill number (SR…).
  final String billNo;
  final String originalBillNo;
  final String date;
  final String customerName;
  final String methodLabel;

  /// Returned products, each with its credit (after discount).
  final List<ReceiptLineItem> returned;
  final List<ReceiptLineItem> replacement;
  final double returnTotal;
  final double newTotal;
  final double netPayable;
  final double collected;
  final double change;

  const SalesReplacementReceipt({
    required this.billNo,
    required this.originalBillNo,
    required this.date,
    required this.customerName,
    required this.methodLabel,
    required this.returned,
    required this.replacement,
    required this.returnTotal,
    required this.newTotal,
    required this.netPayable,
    required this.collected,
    required this.change,
  });
}