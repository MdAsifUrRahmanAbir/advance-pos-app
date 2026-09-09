import 'package:flutter/material.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/common/status_badge.dart';
import '../../data/models/invoice_detail_model.dart';

/// Thin wrapper mapping an [InvoiceDetailStatus] to the right
/// [StatusBadge] color/label. Deliberately its own copy — not the
/// `invoices` feature's `InvoiceStatusBadge` — so `invoice_detail` has
/// no cross-feature widget dependency.
class InvoiceDetailStatusBadge extends StatelessWidget {
  final InvoiceDetailStatus status;
  final bool compact;

  const InvoiceDetailStatusBadge({super.key, required this.status, this.compact = true});

  @override
  Widget build(BuildContext context) {
    final (label, type) = switch (status) {
      InvoiceDetailStatus.paid => (AppStrings.invoiceStatusPaid, StatusBadgeType.success),
      InvoiceDetailStatus.due => (AppStrings.invoiceStatusDue, StatusBadgeType.warning),
      InvoiceDetailStatus.partial => (AppStrings.invoiceStatusPartial, StatusBadgeType.info),
      InvoiceDetailStatus.overdue => (AppStrings.invoiceStatusOverdue, StatusBadgeType.error),
    };
    return StatusBadge(text: label, type: type, compact: compact);
  }
}