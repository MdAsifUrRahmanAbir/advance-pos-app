import 'package:flutter/material.dart';

import 'sales_replacement_mobile_view.dart';

/// Tablet: the same single-column list, centered.
class SalesReplacementTabView extends StatelessWidget {
  const SalesReplacementTabView({super.key});

  static const double _contentMaxWidth = 640; // same width Stock uses

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: _contentMaxWidth),
        child: SalesReplacementMobileView(),
      ),
    );
  }
}