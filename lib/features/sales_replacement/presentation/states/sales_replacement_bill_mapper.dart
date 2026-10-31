import '../../../../core/constants/app_strings.dart';
import '../../../payment/presentation/states/payment_state.dart'
    show ReceiptLineItem;
import '../../../sales_replacement_add/presentation/states/sales_replacement_receipt.dart';
import '../../../sales_replacement_detail/data/models/sales_replacement_detail_model.dart'
    show ResultData;

/// Turns a fetched replacement into the receipt the Bill Preview shows,
/// shares and prints — the same shape the Add flow's success sheet uses.
class SalesReplacementBillMapper {
  const SalesReplacementBillMapper._();

  /// The API returns the same field as a string or a number.
  static double _n(Object? v) =>
      double.tryParse(v?.toString().replaceAll(',', '').trim() ?? '') ?? 0;

  static SalesReplacementReceipt toReceipt(ResultData d) {
    final r = d.resultDataReturn;
    final s = d.replacementSale;
    final methods = s.paymentSystems
        .map((e) => e.name)
        .where((n) => n.isNotEmpty)
        .join(' + ');

    return SalesReplacementReceipt(
      billNo: r.returnBillNo,
      originalBillNo: r.originalSalesBillNo,
      date: r.returnDate,
      customerName: d.customerName,
      methodLabel: methods.isEmpty ? AppStrings.emptyValue : methods,
      // A returned line's credit is its amount less its own discount.
      returned: [
        for (final l in d.returnDetails)
          ReceiptLineItem(
            name: l.productName,
            quantity: _n(l.quantity).round(),
            lineTotal: _n(l.totalAmount) - _n(l.disAmount),
          ),
      ],
      replacement: [
        for (final l in d.replacementDetails)
          ReceiptLineItem(
            name: l.productName,
            quantity: _n(l.quantity).round(),
            lineTotal: _n(l.taAfterDiscount),
          ),
      ],
      returnTotal: _n(r.payableReturnAmount),
      newTotal: _n(s.totalAmount),
      netPayable: _n(s.payableAfterReturn),
      collected: _n(s.givenAmount),
      change: _n(s.changedAmount),
    );
  }
}