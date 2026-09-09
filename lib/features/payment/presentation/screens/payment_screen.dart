import 'package:flutter/material.dart';
import '../../../../core/utils/responsive.dart';
import 'payment_mobile_view.dart';
import 'payment_tab_view.dart';

class PaymentScreen extends StatelessWidget {
  const PaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Responsive(mobile: PaymentMobileView(), tablet: PaymentTabView()),
    );
  }
}
