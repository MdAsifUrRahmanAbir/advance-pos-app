import 'package:flutter/material.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/common/status_badge.dart';
import '../../data/model/invoice_model.dart';

/// Thin wrapper mapping an [InvoiceStatus] to the right [StatusBadge]
/// color/label — mirrors [OrderStatusBadgeWidget]'s pattern of keeping
/// status-to-color mapping in the feature layer.
class InvoiceStatusBadge extends StatelessWidget {
  final InvoiceStatus status;
  final bool compact;

  const InvoiceStatusBadge({super.key, required this.status, this.compact = true});

  @override
  Widget build(BuildContext context) {
    final (label, type) = switch (status) {
      InvoiceStatus.paid => (AppStrings.invoiceStatusPaid, StatusBadgeType.success),
      InvoiceStatus.due => (AppStrings.invoiceStatusDue, StatusBadgeType.warning),
      InvoiceStatus.partial => (AppStrings.invoiceStatusPartial, StatusBadgeType.info),
      InvoiceStatus.overdue => (AppStrings.invoiceStatusOverdue, StatusBadgeType.error),
    };
    return StatusBadge(text: label, type: type, compact: compact);
  }
}