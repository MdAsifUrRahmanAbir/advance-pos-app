import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/responsive.dart';
import 'edit_sale_cart_mobile_view.dart';
import 'edit_sale_cart_tab_view.dart';

class EditSaleCartScreen extends ConsumerWidget {
  final String billNo;

  const EditSaleCartScreen({super.key, required this.billNo});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Responsive(
        mobile: EditSaleCartMobileView(billNo: billNo),
        tablet: EditSaleCartTabView(billNo: billNo),
      ),
    );
  }
}