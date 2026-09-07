import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:template_test/core/utils/responsive.dart';
import 'activity_mobile_view.dart';
import 'activity_tab_view.dart';

class ActivityScreen extends ConsumerWidget {
  const ActivityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Responsive(
          mobile: const ActivityMobileView(),
          tablet: const ActivityTabView(),
        ),
      ),
    );
  }
}
