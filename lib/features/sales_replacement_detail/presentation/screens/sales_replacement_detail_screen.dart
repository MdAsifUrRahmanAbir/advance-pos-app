import 'package:flutter/material.dart';

import '../../../../core/utils/responsive.dart';
import 'sales_replacement_detail_mobile_view.dart';
import 'sales_replacement_detail_tab_view.dart';

class SalesReplacementDetailScreen extends StatelessWidget {
  final String returnBillNo;

  const SalesReplacementDetailScreen({super.key, required this.returnBillNo});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Responsive(
        mobile: SalesReplacementDetailMobileView(returnBillNo: returnBillNo),
        tablet: SalesReplacementDetailTabView(returnBillNo: returnBillNo),
      ),
    );
  }
}