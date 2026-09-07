import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:template_test/core/utils/responsive.dart';
// import '../../../../core/widgets/common/custom_app_bar.dart';
import 'login_mobile_view.dart';
import 'login_tab_view.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      // appBar: CustomAppBar(title: "", showBack: true,),
      body: Responsive(
        mobile: const LoginMobileView(),
        tablet: const LoginTabView(),
      ),
    );
  }
}
