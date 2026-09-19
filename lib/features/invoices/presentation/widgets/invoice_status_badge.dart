import 'package:flutter/material.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/common/status_badge.dart';
import '../../../invoice_detail/presentation/widgets/invoice_detail_status_badge.dart' hide InvoiceComputedStatus;
import '../../data/model/invoices_model.dart';
import '../states/invoice_status.dart';

class InvoiceStatusBadge extends StatelessWidget {
  final ResultDatum invoice;
  final bool compact;

  const InvoiceStatusBadge({super.key, required this.invoice, this.compact = true});

  /// Kept as a static passthrough so existing call sites
  /// (`InvoiceStatusBadge.statusOf(invoice)`) keep working unchanged.
  static InvoiceComputedStatus statusOf(ResultDatum invoice) => invoiceStatusOf(invoice);

  @override
  Widget build(BuildContext context) {
    final status = invoiceStatusOf(invoice);
    final (label, type) = switch (status) {
      InvoiceComputedStatus.paid => (AppStrings.invoicePaidLabel, StatusBadgeType.success),
      InvoiceComputedStatus.due => (AppStrings.invoiceDueLabel, StatusBadgeType.warning),
      InvoiceComputedStatus.partial => (AppStrings.invoiceStatusPartial, StatusBadgeType.info),
    };
    return StatusBadge(text: label, type: type, compact: compact);
  }
}