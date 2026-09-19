import '../../../../core/utils/currency_formatter.dart';
import '../../data/model/invoices_model.dart';

enum InvoiceComputedStatus { paid, due, partial }

/// Derives a paid/due/partial status by comparing [ResultDatum.paidAmount]
/// against [ResultDatum.totalPayableAmount] — the API has no explicit
/// status field. Pulled out of [InvoiceStatusBadge] into its own utility
/// so [InvoicesState.filteredItems] (state/business-logic) can use the
/// same derivation without a state file importing a presentation widget.
InvoiceComputedStatus invoiceStatusOf(ResultDatum invoice) {
  final paid = parseAmount(invoice.paidAmount);
  final payable = parseAmount(invoice.totalPayableAmount);
  if (payable <= 0 || paid >= payable) return InvoiceComputedStatus.paid;
  if (paid <= 0) return InvoiceComputedStatus.due;
  return InvoiceComputedStatus.partial;
}