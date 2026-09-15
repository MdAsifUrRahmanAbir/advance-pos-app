import 'package:flutter/material.dart';
import '../../../../core/utils/responsive.dart';
import 'new_sale_mobile_view.dart';
import 'new_sale_tab_view.dart';

class NewSaleScreen extends StatelessWidget {
  const NewSaleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Responsive(
        mobile: const NewSaleMobileView(),
        tablet: const NewSaleTabView(),
      ),
    );
  }
}
