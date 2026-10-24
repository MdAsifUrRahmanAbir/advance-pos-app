import 'package:flutter/material.dart';
import '../../../../core/utils/responsive.dart';
import 'sales_replacement_add_mobile_view.dart';
import 'sales_replacement_add_tab_view.dart';

class SalesReplacementAddScreen extends StatelessWidget {
  const SalesReplacementAddScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Responsive(
        mobile: SalesReplacementAddMobileView(),
        tablet: SalesReplacementAddTabView(),
      ),
    );
  }
}
