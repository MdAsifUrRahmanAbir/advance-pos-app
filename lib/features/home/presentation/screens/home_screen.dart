import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:template_test/core/utils/responsive.dart';
import 'home_mobile_view.dart';
import 'home_tab_view.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: Scaffold(
        body: Responsive(
          mobile: const HomeMobileView(),
          tablet: const HomeTabView(),
        ),
      ),
    );
  }
}
