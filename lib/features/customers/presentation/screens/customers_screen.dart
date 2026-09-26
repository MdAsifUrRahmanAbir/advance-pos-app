import 'package:flutter/material.dart';
import '../../../../core/utils/responsive.dart';
import 'customers_mobile_view.dart';
import 'customers_tab_view.dart';

class CustomersScreen extends StatelessWidget {
  const CustomersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Responsive(
        mobile: CustomersMobileView(),
        tablet: CustomersTabView(),
      ),
    );
  }
}
