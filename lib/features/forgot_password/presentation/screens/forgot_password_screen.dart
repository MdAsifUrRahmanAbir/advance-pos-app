import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:advance_pos_app/core/utils/responsive.dart';
import 'forgot_password_mobile_view.dart';
import 'forgot_password_tab_view.dart';

class ForgotPasswordScreen extends ConsumerWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Responsive(
        mobile: const ForgotPasswordMobileView(),
        tablet: const ForgotPasswordTabView(),
      ),
    );
  }
}
