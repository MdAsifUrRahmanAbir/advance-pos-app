import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/responsive.dart';
import 'analytics_mode_mobile_view.dart';
import 'analytics_mode_tab_view.dart';

class AnalyticsModeScreen extends ConsumerWidget {
  const AnalyticsModeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Responsive(
        mobile: const AnalyticsMobileView(),
        tablet: const AnalyticsTabView(),
      ),
    );
  }
}
