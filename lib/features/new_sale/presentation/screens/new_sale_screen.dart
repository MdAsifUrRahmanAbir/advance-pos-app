import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/responsive.dart';
import '../widgets/new_sale_top_bar.dart';
import 'new_sale_mobile_view.dart';
import 'new_sale_tab_view.dart';

class NewSaleScreen extends StatelessWidget {
  const NewSaleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: NewSaleTopBar(onBack: () => context.pop(), onScanBarcode: () {}),
      body: Responsive(mobile: NewSaleMobileView(), tablet: NewSaleTabView()),
    );
  }
}
