import '../../../../core/constants/app_strings.dart';
import '../../data/models/sales_replacement_detail_model.dart' show ResultData;

/// Number formatting and share text for the sales replacement detail.
///
/// Money / quantity inputs are `Object?` on purpose: the API returns the
/// same field as a string ("985.00") or a number (985) depending on the
/// record, so every value is parsed from its text form.
class SalesReplacementDetailFormat {
  const SalesReplacementDetailFormat._();

  static num? _parse(Object? raw) =>
      raw == null ? null : num.tryParse(raw.toString().replaceAll(',', '').trim());

  /// '2790' -> '2,790.00'. Unreadable values are returned as they came.
  static String money(Object? raw) {
    final v = _parse(raw);
    if (v == null) {
      final text = raw?.toString() ?? '';
      return text.isEmpty ? AppStrings.emptyValue : text;
    }
    final parts = v.abs().toStringAsFixed(2).split('.');
    final grouped = parts.first.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
          (_) => ',',
    );
    return '${v < 0 ? '-' : ''}$grouped.${parts[1]}';
  }

  /// '1.00' -> '1' · '1.50' -> '1.5'
  static String quantity(Object? raw) {
    final v = _parse(raw);
    if (v == null) {
      final text = raw?.toString() ?? '';
      return text.isEmpty ? AppStrings.emptyValue : text;
    }
    return v == v.roundToDouble() ? v.toInt().toString() : v.toString();
  }

  static bool isPositive(Object? raw) => (_parse(raw) ?? 0) > 0;

  static String names(Iterable<String> items) {
    final joined = items.where((n) => n.isNotEmpty).join(', ');
    return joined.isEmpty ? AppStrings.emptyValue : joined;
  }

  /// Plain-text summary for the share sheet.
  static String shareText(ResultData d) {
    final r = d.resultDataReturn;
    final s = d.replacementSale;
    final b = StringBuffer()
      ..writeln(r.returnBillNo)
      ..writeln('${AppStrings.srdReturnDateLabel}: ${r.returnDate}')
      ..writeln('${AppStrings.srdSalesBillNoLabel}: ${r.originalSalesBillNo}')
      ..writeln('${AppStrings.repdReplacementBillLabel}: ${s.salesBillNo}')
      ..writeln('${AppStrings.invoiceCustomerLabel}: ${d.customerName}')
      ..writeln('${AppStrings.srdReturnByLabel}: ${d.returnBy}')
      ..writeln()
      ..writeln('${AppStrings.repdReturnedSectionTitle}:');
    for (final l in d.returnDetails) {
      b.writeln(
        '• ${l.productName} × ${quantity(l.quantity)} — ${money(l.totalAmount)}',
      );
    }
    b
      ..writeln()
      ..writeln('${AppStrings.repdReplacementSectionTitle}:');
    for (final l in d.replacementDetails) {
      b.writeln(
        '• ${l.productName} × ${quantity(l.quantity)} — ${money(l.taAfterDiscount)}',
      );
    }
    b
      ..writeln()
      ..writeln(
        '${AppStrings.srdPayableLabel}: ${money(r.payableReturnAmount)}',
      )
      ..writeln('${AppStrings.repdGrandTotalLabel}: ${money(s.grandTotal)}')
      ..write(
        '${AppStrings.repdPayableAfterReturnLabel}: ${money(s.payableAfterReturn)}',
      );
    return b.toString();
  }
}