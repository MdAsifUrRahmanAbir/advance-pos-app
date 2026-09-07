import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:template_test/core/utils/responsive.dart';
import 'help_support_mobile_view.dart';
import 'help_support_tab_view.dart';

class HelpSupportScreen extends ConsumerWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Responsive(
        mobile: const HelpSupportMobileView(),
        tablet: const HelpSupportTabView(),
      ),
    );
  }
}
