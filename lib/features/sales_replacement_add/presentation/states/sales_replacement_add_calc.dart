import '../../../../core/utils/currency_formatter.dart' show parseAmount, parseQuantity;
import '../../../invoice_detail/data/models/invoice_detail_model.dart'
    show InvoiceDetailModel;

/// One product line of the ORIGINAL sale, as it can be returned.
class SoldLine {
  final int productId;
  final String name;
  final String barcode;
  final double unitPrice;
  final int soldQty;

  /// Discount percent the line was sold with; the same percent applies to
  /// whatever quantity is returned.
  final double discountRate;

  const SoldLine({
    required this.productId,
    required this.name,
    required this.barcode,
    required this.unitPrice,
    required this.soldQty,
    required this.discountRate,
  });
}

/// A [SoldLine] with the quantity the customer is returning.
class ReturnLine {
  final SoldLine sold;
  final int quantity;

  const ReturnLine({required this.sold, required this.quantity});

  double get gross => SalesReplacementAddCalc.round2(sold.unitPrice * quantity);

  /// rate % × unit price × returned quantity.
  double get discountAmount =>
      SalesReplacementAddCalc.round2(gross * sold.discountRate / 100);

  /// What the customer gets credited for this line.
  double get net => SalesReplacementAddCalc.round2(gross - discountAmount);
}

/// Pure money maths for the replacement flow.
class SalesReplacementAddCalc {
  const SalesReplacementAddCalc._();

  static double round2(double v) => (v * 100).round() / 100;

  static List<SoldLine> soldLines(InvoiceDetailModel? invoice) {
    if (invoice == null) return const [];
    return [
      for (final d in invoice.resultData.saleDetails)
        SoldLine(
          productId: d.productId,
          name: d.productName,
          barcode: d.productBarcode,
          unitPrice: parseAmount(d.unitPrice),
          soldQty: parseQuantity(d.quantity),
          discountRate: parseAmount(d.disRate),
        ),
    ];
  }

  /// Lines with a positive returned quantity, in invoice order.
  static List<ReturnLine> returnLines(
      List<SoldLine> sold,
      Map<int, int> returnQty,
      ) {
    return [
      for (final line in sold)
        if ((returnQty[line.productId] ?? 0) > 0)
          ReturnLine(sold: line, quantity: returnQty[line.productId]!),
    ];
  }
}