import 'package:flutter/material.dart';
import '../../../../core/utils/responsive.dart';
import 'product_mobile_view.dart';
import 'product_tab_view.dart';

class ProductScreen extends StatelessWidget {
  const ProductScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Responsive(
        mobile: ProductMobileView(),
        tablet: ProductTabView(),
      ),
    );
  }
}
