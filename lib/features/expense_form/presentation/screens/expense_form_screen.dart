import 'package:flutter/material.dart';

import '../../../../core/utils/responsive.dart';
import 'expense_form_mobile_view.dart';
import 'expense_form_tab_view.dart';

/// Add (expenseNo == null) or edit an expense.
class ExpenseFormScreen extends StatelessWidget {
  final String? expenseNo;

  const ExpenseFormScreen({super.key, this.expenseNo});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Responsive(
        mobile: ExpenseFormMobileView(expenseNo: expenseNo),
        tablet: ExpenseFormTabView(expenseNo: expenseNo),
      ),
    );
  }
}