import 'package:flutter/material.dart';
import '../../../../core/utils/responsive.dart';
import 'expense_mobile_view.dart';
import 'expense_tab_view.dart';

class ExpenseScreen extends StatelessWidget {
  const ExpenseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Responsive(
        mobile: ExpenseMobileView(),
        tablet: ExpenseTabView(),
      ),
    );
  }
}
