import 'package:flutter/material.dart';

import '../../../../core/utils/responsive.dart';
import 'sales_return_detail_mobile_view.dart';
import 'sales_return_detail_tab_view.dart';

class SalesReturnDetailScreen extends StatelessWidget {
  final String returnBillNo;

  const SalesReturnDetailScreen({super.key, required this.returnBillNo});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Responsive(
        mobile: SalesReturnDetailMobileView(returnBillNo: returnBillNo),
        tablet: SalesReturnDetailTabView(returnBillNo: returnBillNo),
      ),
    );
  }
}