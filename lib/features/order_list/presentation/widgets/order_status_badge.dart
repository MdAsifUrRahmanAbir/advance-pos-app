import 'package:flutter/material.dart';
import '../../../../core/widgets/common/status_badge.dart';

enum OrderStatus { pending, completed, cancelled }

/// Thin wrapper mapping an [OrderStatus] to the right [StatusBadge]
/// color/label — keeps order-specific status logic in the feature
/// layer while reusing the one core badge widget.
class OrderStatusBadgeWidget extends StatelessWidget {
  final OrderStatus status;

  const OrderStatusBadgeWidget({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, type) = switch (status) {
      OrderStatus.pending => ('Pending', StatusBadgeType.warning),
      OrderStatus.completed => ('Completed', StatusBadgeType.success),
      OrderStatus.cancelled => ('Cancelled', StatusBadgeType.error),
    };
    return StatusBadge(text: label, type: type, compact: true);
  }
}