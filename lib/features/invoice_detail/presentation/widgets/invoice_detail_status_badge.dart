import 'package:flutter/material.dart';
import '../../../../core/widgets/common/status_badge.dart';
import '../../data/models/invoice_detail_model.dart';
import '../../data/models/sale_amounts.dart';

enum InvoiceComputedStatus { paid, due, partial }

/// Derives a paid/due/partial badge from [Sale.paidAmount] vs
/// [Sale.totalPayableAmount] — the API has no explicit status field.
class InvoiceDetailStatusBadge extends StatelessWidget {
  final Sale sale;
  final bool compact;

  const InvoiceDetailStatusBadge({
    super.key,
    required this.sale,
    this.compact = true,
  });

  static InvoiceComputedStatus statusOf(Sale sale) {
    final paid = sale.paidAmountValue;
    final payable = sale.totalPayableAmountValue;
    if (payable <= 0 || paid >= payable) return InvoiceComputedStatus.paid;
    if (paid <= 0) return InvoiceComputedStatus.due;
    return InvoiceComputedStatus.partial;
  }

  @override
  Widget build(BuildContext context) {
    final status = statusOf(sale);
    final (label, type) = switch (status) {
      InvoiceComputedStatus.paid => ('Paid', StatusBadgeType.success),
      InvoiceComputedStatus.due => ('Due', StatusBadgeType.warning),
      InvoiceComputedStatus.partial => ('Partial', StatusBadgeType.info),
    };
    return StatusBadge(text: label, type: type, compact: compact);
  }
}
