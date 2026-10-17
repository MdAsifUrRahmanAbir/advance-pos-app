import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/responsive.dart';
import 'edit_sale_payment_mobile_view.dart';
import 'edit_sale_payment_tab_view.dart';

class EditSalePaymentScreen extends ConsumerWidget {
  final String billNo;

  const EditSalePaymentScreen({super.key, required this.billNo});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Responsive(
        mobile: EditSalePaymentMobileView(billNo: billNo),
        tablet: EditSalePaymentTabView(billNo: billNo),
      ),
    );
  }
}