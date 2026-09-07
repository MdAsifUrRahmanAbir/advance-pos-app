import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/responsive.dart';
import '../controllers/cart_controller.dart';
import '../widgets/cart_top_bar.dart';
import 'cart_mobile_view.dart';
import 'cart_tab_view.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Responsive(
        mobile: const CartMobileView(),
        tablet: const CartTabView(),
      ),
    );
  }
}
