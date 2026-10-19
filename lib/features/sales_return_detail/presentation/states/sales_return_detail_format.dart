import '../../../../core/constants/app_strings.dart';
import '../../data/models/sales_return_detail_model.dart';

/// Number formatting and share text for the sales return detail.
class SalesReturnDetailFormat {
  const SalesReturnDetailFormat._();

  static num? _parse(String raw) => num.tryParse(raw.replaceAll(',', '').trim());

  /// '2790' -> '2,790.00'. Unreadable values are returned as they came.
  static String money(String raw) {
    final v = _parse(raw);
    if (v == null) return raw.isEmpty ? AppStrings.emptyValue : raw;
    final parts = v.abs().toStringAsFixed(2).split('.');
    final grouped = parts.first.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
          (_) => ',',
    );
    return '${v < 0 ? '-' : ''}$grouped.${parts[1]}';
  }

  /// '1.00' -> '1' · '1.50' -> '1.5'
  static String quantity(String raw) {
    final v = _parse(raw);
    if (v == null) return raw.isEmpty ? AppStrings.emptyValue : raw;
    return v == v.roundToDouble() ? v.toInt().toString() : v.toString();
  }

  static bool isPositive(String raw) => (_parse(raw) ?? 0) > 0;

  static String names(List<SalesReturnNamedItem> items) {
    final joined = items.map((e) => e.name).where((n) => n.isNotEmpty).join(', ');
    return joined.isEmpty ? AppStrings.emptyValue : joined;
  }

  /// Plain-text summary for the share sheet.
  static String shareText(SalesReturnDetailData d) {
    final r = d.returnInfo;
    final b = StringBuffer()
      ..writeln(r.returnBillNo)
      ..writeln('${AppStrings.srdReturnDateLabel}: ${r.returnDate}')
      ..writeln('${AppStrings.srdSalesBillNoLabel}: ${r.salesBillNo}')
      ..writeln('${AppStrings.customerLabel}: ${d.customerName}')
      ..writeln('${AppStrings.srdReturnByLabel}: ${d.returnBy}')
      ..writeln(
        '${AppStrings.invoicePaymentSystemLabel}: ${names(d.payment.paymentSystems)}',
      )
      ..writeln(
        '${AppStrings.invoicePaymentAccountLabel}: ${names(d.payment.paymentAccounts)}',
      )
      ..writeln()
      ..writeln('${AppStrings.productsTitle}:');
    for (final l in d.returnDetails) {
      b.writeln(
        '• ${l.productName} × ${quantity(l.quantity)} — ${money(l.totalAmount)}',
      );
    }
    b
      ..writeln()
      ..writeln(
        '${AppStrings.invoiceTotalQuantityLabel}: ${quantity(r.totalReturnQuantity)}',
      )
      ..writeln(
        '${AppStrings.srdTotalReturnAmountLabel}: ${money(r.totalReturnAmount)}',
      )
      ..writeln('${AppStrings.invoiceDiscountLabel}: ${money(r.returnDisAmount)}')
      ..write(
        '${AppStrings.srdPayableLabel}: ${money(r.payableReturnAmount)}',
      );
    return b.toString();
  }
}