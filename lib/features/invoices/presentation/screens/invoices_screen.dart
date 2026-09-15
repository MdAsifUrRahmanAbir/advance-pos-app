import 'package:flutter/material.dart';
import '../../../../core/utils/responsive.dart';
import 'invoices_mobile_view.dart';
import 'invoices_tab_view.dart';

class InvoicesScreen extends StatelessWidget {
  const InvoicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Responsive(mobile: InvoicesMobileView(), tablet: InvoicesTabView()),
    );
  }
}
