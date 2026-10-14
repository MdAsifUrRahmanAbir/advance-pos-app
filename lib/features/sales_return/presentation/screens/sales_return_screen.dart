import 'package:flutter/material.dart';
import '../../../../core/utils/responsive.dart';
import 'sales_return_mobile_view.dart';
import 'sales_return_tab_view.dart';

class SalesReturnScreen extends StatelessWidget {
  const SalesReturnScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Responsive(
        mobile: SalesReturnMobileView(),
        tablet: SalesReturnTabView(),
      ),
    );
  }
}
