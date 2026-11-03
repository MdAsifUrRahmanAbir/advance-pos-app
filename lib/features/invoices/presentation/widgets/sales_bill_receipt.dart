import 'package:flutter/material.dart';

import '../../data/model/sales_bill_preview_model.dart';
import 'sales_bill_customer_section.dart';
import 'sales_bill_footer_section.dart';
import 'sales_bill_header_section.dart';
import 'sales_bill_items_section.dart';
import 'sales_bill_paper.dart';
import 'sales_bill_summary_section.dart';

/// The full thermal receipt (paper + every section) for one bill.
/// Everything under [boundaryKey] is what gets printed / shared.
class SalesBillReceipt extends StatelessWidget {
  final SalesBillPreviewModel bill;
  final DateTime? printedAt;
  final GlobalKey boundaryKey;

  const SalesBillReceipt({
    super.key,
    required this.bill,
    required this.printedAt,
    required this.boundaryKey,
  });

  @override
  Widget build(BuildContext context) {
    return SalesBillPaper(
      boundaryKey: boundaryKey,
      children: [
        SalesBillHeaderSection(
          company: bill.company,
          branch: bill.branch,
          counter: bill.counter,
          invoice: bill.invoice,
          printedAt: printedAt,
        ),
        SalesBillItemsSection(rows: bill.productRowData),
        SalesBillSummarySection(summary: bill.summary, payments: bill.payments),
        SalesBillCustomerSection(
          customer: bill.customer,
          employee: bill.employee,
        ),
        SalesBillFooterSection(
          billNo: bill.invoice.salesBillNo,
          config: bill.config,
        ),
      ],
    );
  }
}
