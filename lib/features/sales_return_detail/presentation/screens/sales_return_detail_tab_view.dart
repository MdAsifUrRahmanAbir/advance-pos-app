import 'package:flutter/material.dart';

import 'sales_return_detail_mobile_view.dart';

/// Tablet: the same single-column detail, centered.
class SalesReturnDetailTabView extends StatelessWidget {
  final String returnBillNo;

  const SalesReturnDetailTabView({super.key, required this.returnBillNo});

  static const double _contentMaxWidth = 640; // same width the list uses

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: _contentMaxWidth),
        child: SalesReturnDetailMobileView(returnBillNo: returnBillNo),
      ),
    );
  }
}