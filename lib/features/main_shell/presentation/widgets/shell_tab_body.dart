import 'package:flutter/material.dart';
import '../../../home/presentation/screens/home_screen.dart';
import '../../../analytics_mode/presentation/screens/analytics_mode_screen.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import '../../../stock_screen/presentation/screens/stock_screen_screen.dart';

/// Hosts the four bottom-nav sections (Home, Stock, Report, More) in an
/// [IndexedStack] so switching tabs preserves each screen's scroll
/// position and state instead of rebuilding it from scratch every time.
///
/// "Report" reuses [AnalyticsModeScreen] and "More" reuses [ProfileScreen]
/// since both already cover that content — swap either for a dedicated
/// feature later if its scope grows beyond what those screens offer.
class ShellTabBody extends StatelessWidget {
  final int selectedIndex;

  const ShellTabBody({super.key, required this.selectedIndex});

  static const _screens = [
    HomeScreen(),
    StockScreenScreen(),
    AnalyticsModeScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return IndexedStack(index: selectedIndex, children: _screens);
  }
}