import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/utility/exit_app_alert.dart';
import 'main_shell_mobile_view.dart';
import 'main_shell_tab_view.dart';

class MainShellScreen extends ConsumerWidget {
  const MainShellScreen({super.key});


  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Master data is started by the mobile / tab view (ref.listen).
    return Scaffold(
      extendBody: true,
      body: AppExitAlert(
        child: Responsive(
          mobile: const MainShellMobileView(),
          tablet: const MainShellTabView(),
        ),
      ),
    );
  }
}