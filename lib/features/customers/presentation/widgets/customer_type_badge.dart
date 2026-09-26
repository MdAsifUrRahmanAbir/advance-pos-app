import 'package:flutter/material.dart';
import '../../../../core/widgets/common/status_badge.dart';
import '../states/customer_type.dart';

class CustomerTypeBadge extends StatelessWidget {
  final int type;
  final bool compact;

  const CustomerTypeBadge({super.key, required this.type, this.compact = true});

  @override
  Widget build(BuildContext context) {
    return StatusBadge(
      text: customerTypeLabel(type),
      type: customerTypeBadgeType(type),
      compact: compact,
    );
  }
}