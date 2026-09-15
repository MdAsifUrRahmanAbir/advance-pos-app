import 'package:flutter/material.dart';
import '../../../../core/utils/responsive.dart';
import 'stock_mobile_view.dart';
import 'stock_tab_view.dart';

class StockScreen extends StatelessWidget {
  const StockScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Responsive(mobile: StockMobileView(), tablet: StockTabView()),
    );
  }
}
