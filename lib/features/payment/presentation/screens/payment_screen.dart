import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/responsive.dart';
import '../widgets/payment_top_bar.dart';
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
