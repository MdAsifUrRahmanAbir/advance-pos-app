import 'package:flutter/material.dart';
import '../../../../core/utils/responsive.dart';
import 'sales_replacement_edit_mobile_view.dart';
import 'sales_replacement_edit_tab_view.dart';

class SalesReplacementEditScreen extends StatelessWidget {
  const SalesReplacementEditScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Responsive(
        mobile: SalesReplacementEditMobileView(),
        tablet: SalesReplacementEditTabView(),
      ),
    );
  }
}
