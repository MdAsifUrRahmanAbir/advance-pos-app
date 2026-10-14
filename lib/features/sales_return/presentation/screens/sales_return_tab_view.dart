import 'package:flutter/material.dart';

import 'sales_return_mobile_view.dart';

/// Tablet: the same single-column list, centered.
class SalesReturnTabView extends StatelessWidget {
  const SalesReturnTabView({super.key});

  static const double _contentMaxWidth = 640; // same width Stock uses

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: _contentMaxWidth),
        child: SalesReturnMobileView(),
      ),
    );
  }
}