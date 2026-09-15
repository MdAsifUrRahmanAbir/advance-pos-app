import 'package:flutter/material.dart';
import '../../../../core/utils/responsive.dart';
import 'invoice_detail_mobile_view.dart';
import 'invoice_detail_tab_view.dart';

class InvoiceDetailScreen extends StatelessWidget {
  final String invoiceId;

  const InvoiceDetailScreen({super.key, required this.invoiceId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Responsive(
        mobile: InvoiceDetailMobileView(invoiceId: invoiceId),
        tablet: InvoiceDetailTabView(invoiceId: invoiceId),
      ),
    );
  }
}
