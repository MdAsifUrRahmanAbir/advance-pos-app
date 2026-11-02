import 'package:flutter/material.dart';

import '../../../../core/utils/responsive.dart';
import 'welcome_mobile_view.dart';
import 'welcome_tab_view.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Responsive(
        mobile: WelcomeMobileView(),
        tablet: WelcomeTabView(),
      ),
    );
  }
}