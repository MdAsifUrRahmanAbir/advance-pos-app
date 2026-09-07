import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:template_test/core/utils/responsive.dart';
import 'register_mobile_view.dart';
import 'register_tab_view.dart';

class RegisterScreen extends ConsumerWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Responsive(
        mobile: const RegisterMobileView(),
        tablet: const RegisterTabView(),
      ),
    );
  }
}
