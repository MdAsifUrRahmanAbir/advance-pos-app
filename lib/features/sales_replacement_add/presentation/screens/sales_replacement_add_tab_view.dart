import 'package:flutter/material.dart';

import 'sales_replacement_add_mobile_view.dart';

/// Tablet: the same two-step flow, centered in a single column.
class SalesReplacementAddTabView extends StatelessWidget {
  const SalesReplacementAddTabView({super.key});

  static const double _contentMaxWidth = 640; // same width the list uses

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: _contentMaxWidth),
        child: SalesReplacementAddMobileView(),
      ),
    );
  }
}