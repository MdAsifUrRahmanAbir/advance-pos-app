import 'package:flutter/material.dart';
import '../../../../core/widgets/common/status_badge.dart';
import '../../data/model/invoices_model.dart';

enum InvoiceComputedStatus { paid, due, partial }

/// Derives a paid/due/partial badge by comparing [ResultDatum.paidAmount]
/// against [ResultDatum.totalPayableAmount] — the API has no explicit
/// status field, so this is computed client-side from the two amounts.
class InvoiceStatusBadge extends StatelessWidget {
  final ResultDatum invoice;
  final bool compact;

  const InvoiceStatusBadge({super.key, required this.invoice, this.compact = true});

  static InvoiceComputedStatus statusOf(ResultDatum invoice) {
    final paid = double.tryParse(invoice.paidAmount) ?? 0;
    final payable = double.tryParse(invoice.totalPayableAmount) ?? 0;
    if (payable <= 0 || paid >= payable) return InvoiceComputedStatus.paid;
    if (paid <= 0) return InvoiceComputedStatus.due;
    return InvoiceComputedStatus.partial;
  }

  @override
  Widget build(BuildContext context) {
    final status = statusOf(invoice);
    final (label, type) = switch (status) {
      InvoiceComputedStatus.paid => ('Paid', StatusBadgeType.success),
      InvoiceComputedStatus.due => ('Due', StatusBadgeType.warning),
      InvoiceComputedStatus.partial => ('Partial', StatusBadgeType.info),
    };
    return StatusBadge(text: label, type: type, compact: compact);
  }
}