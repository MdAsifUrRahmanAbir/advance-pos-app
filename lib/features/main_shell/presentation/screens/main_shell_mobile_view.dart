import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../routes/route_names.dart';
import '../controllers/main_shell_controller.dart';
import '../widgets/main_shell_bottom_nav.dart';
import '../widgets/pos_fab_button.dart';
import '../widgets/shell_tab_body.dart';

class MainShellMobileView extends ConsumerWidget {
  const MainShellMobileView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(mainShellControllerProvider);

    return Scaffold(
      extendBody: true,
      body: ShellTabBody(selectedIndex: selectedIndex),
      floatingActionButton: PosFabButton(
        onTap: () {
          context.push(RouteNames.newSale);
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: Material(
        color: Colors.transparent,
        child: MainShellBottomNav(
          selectedIndex: selectedIndex,
          onSelected: (index) =>
              ref.read(mainShellControllerProvider.notifier).selectTab(index),
        ),
      ),
    );
  }
}
