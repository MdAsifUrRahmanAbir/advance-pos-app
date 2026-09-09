import 'package:advance_pos_app/features/invoices/presentation/screens/invoices_screen.dart';
import 'package:flutter/material.dart';
import '../../../home/presentation/screens/home_screen.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import '../../../stock/presentation/screens/stock_screen.dart';

class ShellTabBody extends StatelessWidget {
  final int selectedIndex;

  const ShellTabBody({super.key, required this.selectedIndex});

  static const _screens = [
    HomeScreen(),
    StockScreen(),
    // ProductScreen(),
    // AnalyticsModeScreen(),
    InvoicesScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return IndexedStack(index: selectedIndex, children: _screens);
  }
}