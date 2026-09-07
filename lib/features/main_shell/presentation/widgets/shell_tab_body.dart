import 'package:flutter/material.dart';
import '../../../analytics_mode/presentation/screens/analytics_mode_screen.dart';
import '../../../home/presentation/screens/home_screen.dart';
import '../../../activity/presentation/screens/activity_screen.dart';
import '../../../order_list/presentation/screens/order_list_screen.dart';
import '../../../profile/presentation/screens/profile_screen.dart';

/// Hosts all five bottom-nav destination screens in an [IndexedStack]
/// so switching tabs preserves each screen's scroll position and
/// state instead of rebuilding it from scratch every time.
class ShellTabBody extends StatelessWidget {
  final int selectedIndex;

  const ShellTabBody({super.key, required this.selectedIndex});

  static const _screens = [
    HomeScreen(),
    ActivityScreen(),
    AnalyticsModeScreen(),
    OrderListScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return IndexedStack(index: selectedIndex, children: _screens);
  }
}