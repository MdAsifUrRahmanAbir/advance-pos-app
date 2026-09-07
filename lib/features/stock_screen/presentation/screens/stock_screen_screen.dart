import 'package:flutter/material.dart';
import '../../../../core/utils/responsive.dart';
import 'stock_screen_mobile_view.dart';
import 'stock_screen_tab_view.dart';

class StockScreenScreen extends StatelessWidget {
  const StockScreenScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Responsive(
        mobile: StockScreenMobileView(),
        tablet: StockScreenTabView(),
      ),
    );
  }
}
