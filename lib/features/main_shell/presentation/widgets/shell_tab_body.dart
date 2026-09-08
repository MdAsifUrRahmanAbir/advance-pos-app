import 'package:advance_pos_app/features/product/presentation/screens/product_screen.dart';
import 'package:flutter/material.dart';
import '../../../home/presentation/screens/home_screen.dart';
import '../../../analytics_mode/presentation/screens/analytics_mode_screen.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import '../../../stock_screen/presentation/screens/stock_screen_screen.dart';

class ShellTabBody extends StatelessWidget {
  final int selectedIndex;

  const ShellTabBody({super.key, required this.selectedIndex});

  static const _screens = [
    HomeScreen(),
    // StockScreenScreen(),
    ProductScreen(),
    AnalyticsModeScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return IndexedStack(index: selectedIndex, children: _screens);
  }
}