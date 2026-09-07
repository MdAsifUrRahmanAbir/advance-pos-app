import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:template_test/core/utils/responsive.dart';
import 'reset_password_mobile_view.dart';
import 'reset_password_tab_view.dart';

class ResetPasswordScreen extends ConsumerWidget {
  const ResetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Responsive(
        mobile: const ResetPasswordMobileView(),
        tablet: const ResetPasswordTabView(),
      ),
    );
  }
}
