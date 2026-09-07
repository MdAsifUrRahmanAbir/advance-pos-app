import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/common/custom_bottom_nav.dart';
import '../controllers/main_shell_controller.dart';
import '../widgets/shell_tab_body.dart';
import '../widgets/shell_navigation_item.dart';

class MainShellMobileView extends ConsumerWidget {
  const MainShellMobileView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(mainShellControllerProvider);

    return Scaffold(
      body: ShellTabBody(selectedIndex: selectedIndex),
      bottomNavigationBar: CustomBottomNav(
        selectedIndex: selectedIndex,
        onSelected: (index) => ref.read(mainShellControllerProvider.notifier).selectTab(index),
        indicatorColor: Colors.transparent,
        destinations: [
          for (final item in shellNavItems)
            NavigationDestination(
              icon: Icon(item.icon),
              selectedIcon: Icon(item.selectedIcon),
              label: item.label,
            ),
        ],
      ),
    );
  }
}